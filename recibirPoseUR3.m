function dataString=recibirPoseUR3()
% Parámetros del puerto
port = 50000; % Puerto para la comunicación

% Crear un objeto TCP/IP como servidor
tcpServer = tcpserver(port, 'Timeout', 10);
disp('Servidor iniciado. Esperando datos...');

% Tiempo máximo para escuchar antes de cerrar (en segundos)
maxListenTime = 60; % Ajusta el tiempo según sea necesario
startTime = tic; % Tiempo de inicio

% Leer datos del servidor
try
    while toc(startTime) < maxListenTime
        % Verificar si hay datos disponibles
        if tcpServer.NumBytesAvailable > 0
            % Leer los datos del cliente
            data = read(tcpServer, tcpServer.NumBytesAvailable, "char");
            % Convertir los datos en una cadena de texto
            dataString = char(data);
            % Mostrar los datos recibidos en una sola línea
            disp(['Datos recibidos: ' dataString]);
            break;
        end
        
        % Pausa para evitar sobrecargar el CPU
        pause(0.1);
    end
catch ME
    % Manejo de errores
    disp(['Error: ' ME.message]);
end

% Cerrar el servidor cuando termines
disp('Servidor finalizado.');
clear tcpServer;
end