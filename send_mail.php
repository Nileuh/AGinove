<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $to = 'aginove.web@gmail.com';
    $subject = 'Nouveau message depuis le formulaire de contact AGinove';

    // Sécurisation et récupération des champs
    $name = htmlspecialchars(trim($_POST['name'] ?? ''));
    $email = htmlspecialchars(trim($_POST['email'] ?? ''));
    $phone = htmlspecialchars(trim($_POST['phone'] ?? ''));
    $company = htmlspecialchars(trim($_POST['company'] ?? ''));
    $service = htmlspecialchars(trim($_POST['service'] ?? ''));
    $budget = htmlspecialchars(trim($_POST['budget'] ?? ''));
    $message = htmlspecialchars(trim($_POST['message'] ?? ''));

    // Construction du message
    $body = "<h2>Nouveau message de contact</h2>"
        . "<p><strong>Nom :</strong> $name</p>"
        . "<p><strong>Email :</strong> $email</p>"
        . "<p><strong>Téléphone :</strong> $phone</p>"
        . "<p><strong>Entreprise :</strong> $company</p>"
        . "<p><strong>Type de projet :</strong> $service</p>"
        . "<p><strong>Budget estimé :</strong> $budget</p>"
        . "<p><strong>Message :</strong><br>" . nl2br($message) . "</p>";

    // Headers pour email HTML
    $headers = "MIME-Version: 1.0" . "\r\n";
    $headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";
    $headers .= "From: $name <$email>" . "\r\n";

    // Envoi de l'email
    $success = mail($to, $subject, $body, $headers);

    if ($success) {
        // Redirection ou message de confirmation
        header('Location: contact.html?success=1');
        exit();
    } else {
        header('Location: contact.html?error=1');
        exit();
    }
} else {
    // Accès direct interdit
    header('Location: contact.html');
    exit();
} 