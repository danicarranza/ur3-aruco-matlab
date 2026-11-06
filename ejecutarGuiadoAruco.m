function ejecutarGuiadoAruco()
   
    %% Ejecutar función para búsqueda del código
    iniciarProgramaUR3();
   % foundMarker = false;
    
    %% Seleccionar el tipo de código
     % Iniciar socket_server en paralelo usando parfeval
   % Inicializar la variable global
    
    esperarDeteccionAruco();
    close all;
    pause(1);
    [foundMarker, detectedFamily] = detectarAruco();

    %% Detectar la posición del código respecto a la cámara
    pause(1);
if foundMarker
    disp(['Se encontró un marcador ArUco de la familia: ', detectedFamily]);
  [T_marker, T_pinza_marker] = estimarPoseAruco();

else
    disp('No se encontró ningún marcador ArUco.');
    %
end
    %% Transformar de vector a matrices 


    % Vector a matriz cámara pieza

%transformationMatrix = detectArucoAndComputeTransform();
disp('Matriz de transformación homogénea:');
%disp(T_marker);


    %Vector a matriz camara pinza 
%disp(T_pinza_marker);


    %Vector a matriz base pinza
% Obtener datos del robot
dataString = recibirPoseUR3(); % Llama a la función que recibe los datos

% Asegúrate de que dataString no esté vacío y tenga el formato correcto
if isempty(dataString) || length(dataString) < 10
    error('Datos recibidos están vacíos o mal formateados.');
end

% Extraer el contenido numérico del string de datos
% Eliminar el prefijo 'p[' y el sufijo ']'
dataString = dataString(3:end-1); 
%display("hola"+dataString);

% Descomponer el vector de datos
p = str2double(strsplit(dataString, ','));

% Verificar que el vector tiene 6 elementos
if length(p) ~= 6
    error('Formato de datos incorrecto.');
end

% Extraer valores
x = p(1);
y = p(2);
z = p(3);
roll = p(4);
pitch = p(5);
yaw = p(6);

% Mostrar los ángulos en radianes para depuración
disp(['Ángulos (en radianes) - Roll: ', num2str(roll), ', Pitch: ', num2str(pitch), ', Yaw: ', num2str(yaw)]);

% % Crear las matrices de rotación usando el orden ZYX
% Rz = [cos(yaw), -sin(yaw), 0;
%       sin(yaw),  cos(yaw), 0;
%       0,         0,        1];
% 
% Ry = [cos(pitch), 0, sin(pitch);
%       0,          1, 0;
%      -sin(pitch), 0, cos(pitch)];
% 
% Rx = [1, 0,         0;
%      0, cos(roll), -sin(roll);
%      0, sin(roll),  cos(roll)];
% 
% % Matriz de rotación final
% R = Rx * Ry * Rz;
%R=eul2rotm([roll,pitch,yaw],'XYZ'); % Orden 'ZYX': yaw, pitch, roll
v = [roll,pitch,yaw];  % Vector de rotación
theta = norm(v);  % Ángulo de rotación
k = v / theta;    % Eje de rotación (normalizado)

axang = [k, theta];  % Vector ángulo-eje
R = axang2rotm(axang);

% Construir la matriz de transformación homogénea 4x4
transformationMatrixRobot = eye(4); % Inicializar como matriz identidad 4x4
transformationMatrixRobot(1:3, 1:3) = R; % Colocar la matriz de rotación
transformationMatrixRobot(1:3, 4) = [x; y; z]; % Colocar el vector de traslación

% Mostrar la matriz de transformación
%disp('Matriz de Transformación Homogénea:');
%disp(transformationMatrixRobot);


%Multiplicar matrices 
%resultMatrix = matrixCamPinza * transformationMatrixRobot;
% Multiplicar matrices
% transformationMatrix  camara ojeto 
% matrizCamPinza pinza camara
% transformationMatrixRobot base pinza
% rotar pi grados
% 1ª fallo resultMatrix = transformationMatrix * matrixCamPinza * transformationMatrixRobot;

% Operaciones de transformación
resultMatrix = transformationMatrixRobot * T_pinza_marker;

% Extraer la matriz de rotación y el vector de traslación
rotationMatrix = resultMatrix(1:3, 1:3);  % Matriz de rotación
% Matriz de rotación de pi radianes alrededor del eje X
Rx_pi = [1, 0, 0;
         0, -1, 0;
         0, 0, -1];
% Multiplicar la matriz de rotación original por la rotación alrededor de X en pi
rotationMatrix = Rx_pi * rotationMatrix;
 Rz_90 = [cos(pi/2), -sin(pi/2), 0;
          sin(pi/2),  cos(pi/2), 0;
          0,         0,        1];
 

rotationMatrix= Rz_90*rotationMatrix;

translationVector = resultMatrix(1:3, 4);  % Vector de traslación

% Convertir la matriz de rotación a un vector ángulo-eje
axang = rotm2axang(rotationMatrix);  % axang = [kx, ky, kz, theta]



% Convertir el vector ángulo-eje en un vector de rotación
rotationVector = axang(1:3) * axang(4);  % Multiplicamos el eje por el ángulo para obtener el vector de rotación

% Formar el vector con exactamente 6 elementos (3 de posición y 3 del vector de rotación)
% Nota: translationVector es un vector columna 3x1, rotationVector es un vector fila 1x3

% Convertir translationVector a fila
translationVector = translationVector(:)';  % Asegurarse de que sea una fila 1x3

% Concatenar los vectores de traslación y vector de rotación
vectorResult = [translationVector, rotationVector];

% Verificar el tamaño del vector
if length(vectorResult) ~= 6
    error('El vectorResult debe tener exactamente 6 elementos.');
end

% Mostrar el resultado
%disp('Resultado como vector:');
%disp(vectorResult);

% Convertir el vector a una cadena de texto en el formato p[...]
% Usar sprintf para cada elemento y concatenar los resultados
formattedVector = ['p[' sprintf('%.5f,', vectorResult(1:end-1)) sprintf('%.5f', vectorResult(end)) ']'];

% Mostrar el resultado
disp('Vector como cadena:');
disp(formattedVector);

moverUR3YEjecutarPrograma(formattedVector);


    %% Ordenar al UR3 moverse la nueva posición menos 0.1 en Z






end