<?php
session_start();
include 'db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nombreUsuario = $_POST['nombreUsuario'];
    $contraseña = $_POST['contraseña'];

    // Verificar las credenciales
    $sql = "SELECT * FROM usuarios WHERE NombreUsuario = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$nombreUsuario]);
    $user = $stmt->fetch();

    if ($user && password_verify($contraseña, $user['Contraseña'])) {
        // Credenciales válidas
        $_SESSION['usuario'] = $user['NombreUsuario'];
        $_SESSION['esAdmin'] = $user['esAdmin']; // Guardar el rol del usuario en la sesión
        header("Location: dashboard.php");
        exit();
    } else {
        echo "Usuario o contraseña incorrectos.";
    }
} else {
    echo "Método de solicitud no permitido.";
}
?>

