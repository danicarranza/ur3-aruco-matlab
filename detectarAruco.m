function [foundMarker, detectedFamily] = detectarAruco()
    % Limpieza de la consola
    clc;
    
    % Conectar a la Raspberry Pi
    rpiPassword = getenv('UR_ARUCO_RPI_PASSWORD');
    if isempty(rpiPassword)
        error('Configura la variable de entorno UR_ARUCO_RPI_PASSWORD antes de ejecutar.');
    end
    rpi = raspi('10.52.17.116', 'pi', rpiPassword);

    % Conectar a la cámara y configurar la resolución
    cam = cameraboard(rpi, 'Resolution', '640x480'); % Asegúrate de que esta resolución coincide con la utilizada durante la calibración

    foundMarker = false;
    detectedFamily = {};
    markerDetectedTime = 0; % Inicializar el tiempo de detección

    % Bucle infinito para la detección continua
    while ~foundMarker || toc(markerDetectedTime) < 1
        % Capturar una imagen
        I = snapshot(cam);
        
        % Detectar marcadores ArUco
        [ids, locs, detectedFamily] = readArucoMarker(I);

        % Verificar si se encontraron marcadores
        numMarkers = length(ids);

        if numMarkers > 0
            if ~foundMarker
                foundMarker = true;
                markerDetectedTime = tic; % Iniciar el temporizador cuando se detecta el primer marcador
            end
        else
            foundMarker = false; % Restablecer si no se detectan marcadores
        end

        for i = 1:numMarkers
            loc = locs(:,:,i);
            
            % Mostrar el ID y la familia del marcador detectado
            disp("Detected marker ID, Family: " + ids(i) + ", " + detectedFamily{i});

            % Insertar los bordes del marcador
            I = insertShape(I, "polygon", {loc}, 'Opacity', 1, 'Color', "green", 'LineWidth', 4);

            % Insertar las esquinas del marcador
            markerRadius = 6;
            numCorners = size(loc, 1);
            markerPosition = [loc, repmat(markerRadius, numCorners, 1)];
            I = insertShape(I, "FilledCircle", markerPosition, 'Color', "red", 'Opacity', 1);

            % Insertar los IDs de los marcadores
            center = mean(loc);
            I = insertText(I, center, num2str(ids(i)), 'FontSize', 30, 'BoxOpacity', 1);
        end

        % Mostrar la imagen procesada
        imshow(I);
        pause(0.1);
    end
    % Aquí puedes añadir una condición para salir del bucle, como una tecla presionada
end
