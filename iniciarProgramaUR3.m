function iniciarProgramaUR3

    disp('Ejecutando la función UR3 coger pieza...');

    % Crear conexión TCP con el robot (puerto 30002)
    t = tcpclient("10.52.17.106", 30002, "Timeout", 20); 
    
    % Crear y abrir la conexión con el Dashboard Server (puerto 29999)
    d = tcpip("10.52.17.106", 29999, 'NetworkRole', 'client');
    fopen(d);
    pause(1);

    % Limpiar buffers TCP
    flush(t, "input");
    datosRx = read(t, 1150);
    flush(t, "output"); 

    % Crear el comando movep con el vector formateado
   
    % Cargar el programa en el robot
    fprintf(d, 'load test_calib_cam.urp\n');

    % No esperar la respuesta del robot, cerrar la conexión inmediatamente
    pause(0.5);  % Pausa corta para dar tiempo a cargar el programa (si es necesario)

    % Ejecutar el programa (sin esperar respuesta)
    fprintf(d, 'play\n');

    % Cerrar conexiones inmediatamente, independientemente de lo que haga el robot
    clear t;  % Cerrar conexión TCP con el robot
    fclose(d);  % Cerrar conexión con el Dashboard Server
    delete(d);  % Borrar el objeto de conexión
    clear d;

    disp('Conexión cerrada. El robot sigue ejecutando el programa.');
    
end
