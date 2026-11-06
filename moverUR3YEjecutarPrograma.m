function moverUR3YEjecutarPrograma(formattedVector)
    
    disp('Ejecutando la función UR3 coger pieza...');
    
    % Crear conexión TCP
    t = tcpclient("10.52.17.106", 30002, "Timeout", 20);
    fopen(t);
    
    % Crear y abrir la conexión con el Dashboard Server
    d = tcpip("10.52.17.106", 29999, 'NetworkRole', 'client');
    fopen(d);
    pause(1);


    % Limpiar buffers
    flush(t, "input");
    datosRx = read(t, 1150);
    flush(t, "output"); 
   % Forzar pos a un valor específico como cadena formateada
    command = ['movep(', formattedVector, ', a=0.02, v=0.02, r=0)'];

    % Enviar el comando al socket
    writeline(t, command);

    pause(17);

    fprintf(d, 'load cogerpieza.urp\n');
    pause(5);
    % Leer la respuesta del robot
    response = fgets(d);
    disp(['Respuesta del robot al cargar: ', response]);
    pause(5);

    %Coger pieza
    fprintf(d, 'play\n');
    pause(7);
    response = fgets(d);
    disp(['Respuesta del robot al ejecutar: ', response]);

    % Cerrar conexión
    clear t;
    
    disp('El brazo UR3 está moviendo la taza...');
    fclose(d);
delete(d);
clear d;
end
