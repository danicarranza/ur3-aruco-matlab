function esperarDeteccionAruco()
    % Declarar la variable global para controlar la ejecución
    global detenerSocket;
    detenerSocket = false; % Inicialización de la variable
    pause(1);
    % Crear un socket TCP/IP
    t = tcpip('10.52.17.106', 50000, 'NetworkRole', 'server');

    % Abrir el socket
    fopen(t);
  % Comando para cargar el programa .urp
   

    % Bucle del socket que seguirá ejecutándose mientras no se encuentre el marcador
    while ~detenerSocket
        % Verificar si se ha detectado un código ArUco
        [foundMarker, detectedFamily] = detectarAruco(); % Llamar a la función de detección

        if foundMarker
            % Enviar el comando cuando se detecta el código ArUco
            sMsgAnswer = '(0,0,0,0,0,1)';
          %  disp('Código ArUco detectado, enviando comando de cierre...');
            fwrite(t, [sMsgAnswer, newline], 'char');
            detenerSocket = true; % Indicar que se detenga el socket
        end

        % Esperar a que haya una conexión disponible
        if t.BytesAvailable > 0
            % Leer los datos disponibles
            data = fread(t, t.BytesAvailable, 'char');
            response = char(data');
            response = strtrim(response);  % Quitar espacios en blanco

            % Mostrar la respuesta recibida
            disp(['Respuesta: ', response]);

            % Verificar si la conexión debe cerrarse
            if strcmp(response, 'closing socket')
                disp('Cerrando conexión...');
                fclose(t);
                delete(t);
                clear t;
                break;
            end

            if ~isempty(sMsgAnswer)
                disp(['Enviando respuesta: ', sMsgAnswer]);
                fwrite(t, [sMsgAnswer, newline], 'char');
            end
        end

        % Añadir una pausa pequeña para evitar un bucle ocupado
        pause(0.3);
    end

    % Cerrar el socket si se detectó un marcador
    if detenerSocket
        disp('Marcador detectado, cerrando conexión del socket...');
        fclose(t);
        delete(t);
        clear t;
    end
end
