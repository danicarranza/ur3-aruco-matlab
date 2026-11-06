function [T_marker, T_pinza_marker] = estimarPoseAruco()

%% Detector posición ARUCO Planos 3D
% Obtener posición x y z con respecto a la cámara
close all;
clear all;
clc;

% Conectar a la Raspberry Pi
rpiPassword = getenv('UR_ARUCO_RPI_PASSWORD');
if isempty(rpiPassword)
    error('Configura la variable de entorno UR_ARUCO_RPI_PASSWORD antes de ejecutar.');
end
rpi = raspi('10.52.17.116', 'pi', rpiPassword);

% Conectar a la cámara
cam = cameraboard(rpi, 'Resolution', '640x480');

% Cargar las intrinsics de la cámara
data = load("intrinsecosCamaraRaspberry.mat");
intrinsics = data.intrinsics;

% Verificar que las intrinsics corresponden a la resolución actual
if ~isequal([intrinsics.ImageSize(2), intrinsics.ImageSize(1)], size(snapshot(cam), [2 1]))
    error('La resolución de la cámara no coincide con la resolución utilizada durante la calibración');
end

% Especificar el tamaño del marcador y la familia del marcador
%markerSizeInMM = 18;
markerSizeInMM = 28;


markerFamily = "DICT_4X4_100";

% Definir la posición de la pinza respecto a la cámara (en metros y radianes)
pinza_pos = [-0.09, -0.012, -0.195]; % [x, y, z] en metros

%pinza_pos = [-0.09, -0.012, -0.18];
pinza_rot_z = 1.57; % Rotación alrededor del eje Z en radianes

% Crear la matriz de traslación para la pinza
T_pinza = eye(4);  % Matriz identidad 4x4
T_pinza(1:3, 4) = pinza_pos';  % Añadir la traslación [x, y, z]

%_pinza Crear la matriz de rotación para la pinza (solo rotación en Z)
R_pinza_z=eul2rotm([0,0,pinza_rot_z],'XYZ');
% R_pinza_z = [cos(pinza_rot_z) -sin(pinza_rot_z) 0;
%              sin(pinza_rot_z)  cos(pinza_rot_z) 0;
%              0                0               1];

% Añadir la rotación a la matriz de transformación de la pinza
T_pinza(1:3, 1:3) = R_pinza_z;

% Bucle infinito para capturar y procesar imágenes en tiempo real
%while true
    % Capturar una imagen
    I = snapshot(cam);
    
    % Corregir la distorsión de la imagen
    [I, camIntrinsics] = undistortFisheyeImage(I, intrinsics);
    
    % Estimar las poses de los marcadores
    [ids, locs, poses] = readArucoMarker(I, markerFamily, camIntrinsics, markerSizeInMM);
    
    % Origen y vectores de ejes para el sistema de coordenadas del objeto
    worldPoints = [0 0 0; markerSizeInMM/2 0 0; 0 markerSizeInMM/2 0; 0 0 markerSizeInMM/2];
    
    % Superponer las poses estimadas en la imagen para visualización
    for i = 1:length(poses)
        % Obtener coordenadas de imagen para los ejes
        imagePoints = world2img(worldPoints, poses(i), camIntrinsics);
        
        % Puntos de los ejes en la imagen
        axesPoints = [imagePoints(1,:) imagePoints(2,:);
                      imagePoints(1,:) imagePoints(3,:);
                      imagePoints(1,:) imagePoints(4,:)];
        
        % Dibujar los ejes coloreados
        I = insertShape(I, "Line", axesPoints, ...
            'Color', ["red","green","blue"], 'LineWidth', 5);
        
        % Obtener la posición del marcador (x, y, z) desde el vector de traslación
        translationVector = poses(i).Translation; % Vector de traslación (x, y, z) en milímetros
        x = translationVector(1) / 1000; % Convertir a metros
        y = translationVector(2) / 1000; % Convertir a metros
        z = translationVector(3) / 1000; % Convertir a metros
        
        % Calcular la distancia al marcador
        distanceToMarker = norm(translationVector) / 1000; % Distancia en metros
        
        % Obtener la matriz de rotación del marcador
        rotationMatrix = poses(i).Rotation; % Matriz de rotación 3x3
        
        % Convertir la matriz de rotación a ángulos de Euler (en radianes)
        eulerAngles = rotm2eul(rotationMatrix, 'XYZ');
        yaw = eulerAngles(1);
        pitch = eulerAngles(2);
        roll = eulerAngles(3);
        
        % Crear la matriz de transformación del marcador respecto a la cámara
        T_marker = eye(4);  % Matriz identidad 4x4
        T_marker(1:3, 1:3) = rotationMatrix;  % Asignar la rotación
        T_marker(1:3, 4) = [x; y; z];  % Asignar la traslación
        
        % Multiplicar la matriz de la pinza con la matriz del marcador respecto a la cámara
        T_pinza_marker = T_pinza * T_marker;
        
        % Extraer la posición y rotación de la pinza respecto al marcador
        pinza_x = T_pinza_marker(1, 4);
        pinza_y = T_pinza_marker(2, 4);
        pinza_z = T_pinza_marker(3, 4);
        
        % Extraer la rotación de la pinza respecto al marcador
        R_pinza_marker = T_pinza_marker(1:3, 1:3);
        eulerAngles_pinza = rotm2eul(R_pinza_marker, 'XYZ');
        pinza_yaw = eulerAngles_pinza(1);
        pinza_pitch = eulerAngles_pinza(2);
        pinza_roll = eulerAngles_pinza(3);
        
        % Mostrar la distancia, las coordenadas (x, y, z) y la rotación en la imagen
        positionText = sprintf('ID: %d, Dist: %.2f m, X: %.3f, Y: %.3f, Z: %.3f', ...
                               ids(i), distanceToMarker, x, y, z);
        rotationText = sprintf('Yaw: %.2f rad, Pitch: %.2f rad, Roll: %.2f rad', yaw, pitch, roll);
        pinzaText = sprintf('Pinza X: %.3f, Y: %.3f, Z: %.3f', pinza_x, pinza_y, pinza_z);
        pinzaRotText = sprintf('Pinza Yaw: %.2f rad, Pitch: %.2f rad, Roll: %.2f rad', ...
                               pinza_yaw, pinza_pitch, pinza_roll);
        
        % Insertar texto en la imagen
        I = insertText(I, [10, 10 + 50 * (i-1)], positionText, ...
            'FontSize', 20, 'BoxOpacity', 0.7, 'TextColor', 'white');
        I = insertText(I, [10, 10 + 50 * (i-1) + 25], rotationText, ...
            'FontSize', 20, 'BoxOpacity', 0.7, 'TextColor', 'white');
        I = insertText(I, [10, 10 + 50 * (i-1) + 50], pinzaText, ...
            'FontSize', 20, 'BoxOpacity', 0.7, 'TextColor', 'yellow');
        I = insertText(I, [10, 10 + 50 * (i-1) + 75], pinzaRotText, ...
            'FontSize', 20, 'BoxOpacity', 0.7, 'TextColor', 'cyan');
    end
    
    % Mostrar los resultados
    imshow(I);
    drawnow; % Actualizar la figura
    pause(2);
%end
end
