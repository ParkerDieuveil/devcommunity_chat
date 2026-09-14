import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_controller.dart';

final appStringsProvider = Provider<AppStrings>((ref) {
  return AppStrings(ref.watch(localeProvider));
});

/// Chaînes UI légères FR/EN (sans ARB — suffisant pour le camp).
class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  bool get isFrench => locale.languageCode == 'fr';

  // —— App / nav ——
  String get appName => 'DevCommunity Chat';
  String get moreTitle => isFrench ? 'Plus' : 'More';
  String get navChats => isFrench ? 'Chats' : 'Chats';
  String get navGroups => isFrench ? 'Groupes' : 'Groups';
  String get navProfile => isFrench ? 'Profil' : 'Profile';
  String get navMore => isFrench ? 'Plus' : 'More';

  // —— More ——
  String get language => isFrench ? 'Langue' : 'Language';
  String get french => 'Français';
  String get english => 'English';
  String get darkMode => isFrench ? 'Mode sombre' : 'Dark Mode';
  String get muteNotifications =>
      isFrench ? 'Couper les notifs' : 'Mute Notification';
  String get joinedGroups =>
      isFrench ? 'Groupes rejoints' : 'Joined Groups';
  String get aboutApp => isFrench ? 'À propos' : 'About App';
  String get replayIntro => isFrench ? 'Revoir l\'intro' : 'Replay intro';
  String get logout => isFrench ? 'Déconnexion' : 'Logout';

  // —— Common ——
  String get cancel => isFrench ? 'Annuler' : 'Cancel';
  String get add => isFrench ? 'Ajouter' : 'Add';
  String get save => isFrench ? 'Enregistrer' : 'Save';
  String get close => isFrench ? 'Fermer' : 'Close';
  String get search => isFrench ? 'Rechercher' : 'Search';
  String get sessionRequired =>
      isFrench ? 'Session requise' : 'Sign-in required';
  String get userFallback => isFrench ? 'Utilisateur' : 'User';
  String get groupFallback => isFrench ? 'Groupe' : 'Group';
  String get noMessagePreview =>
      isFrench ? 'Aucun message' : 'No messages';
  String get comingSoon =>
      isFrench ? 'bientôt disponible' : 'coming soon';
  String get copiedToClipboard => isFrench
      ? 'Copié dans le presse-papiers'
      : 'Copied to clipboard';

  // —— Auth ——
  String get loginSubtitle => isFrench
      ? 'Connectez-vous à votre communauté.'
      : 'Sign in to your community.';
  String get registerSubtitle => isFrench
      ? 'Créez votre compte et rejoignez la communauté.'
      : 'Create your account and join the community.';
  String get email => 'Email';
  String get emailHint => 'vous@example.com';
  String get password => isFrench ? 'Mot de passe' : 'Password';
  String get confirmPassword =>
      isFrench ? 'Confirmer le mot de passe' : 'Confirm password';
  String get showPassword =>
      isFrench ? 'Afficher le mot de passe' : 'Show password';
  String get hidePassword =>
      isFrench ? 'Masquer le mot de passe' : 'Hide password';
  String get signIn => isFrench ? 'Se connecter' : 'Sign in';
  String get signUp => isFrench ? 'Créer mon compte' : 'Create account';
  String get noAccountYet =>
      isFrench ? 'Pas encore de compte ? ' : 'No account yet? ';
  String get createAccount =>
      isFrench ? 'Créer un compte' : 'Create an account';
  String get alreadyHaveAccount =>
      isFrench ? 'Vous avez déjà un compte ? ' : 'Already have an account? ';
  String get emailRequired =>
      isFrench ? 'Veuillez entrer votre email.' : 'Please enter your email.';
  String get passwordRequired => isFrench
      ? 'Veuillez entrer votre mot de passe.'
      : 'Please enter your password.';
  String get invalidEmail => isFrench
      ? 'Veuillez entrer une adresse email valide.'
      : 'Please enter a valid email address.';
  String get passwordMinLength => isFrench
      ? 'Minimum 6 caractères.'
      : 'At least 6 characters.';
  String get confirmPasswordRequired => isFrench
      ? 'Veuillez confirmer votre mot de passe.'
      : 'Please confirm your password.';
  String get passwordsDoNotMatch => isFrench
      ? 'Les mots de passe ne correspondent pas.'
      : 'Passwords do not match.';
  String get authUserNotFound => isFrench
      ? 'Aucun compte associé à cet email.'
      : 'No account found for this email.';
  String get authWrongCredentials => isFrench
      ? 'Email ou mot de passe incorrect.'
      : 'Incorrect email or password.';
  String get authTooManyRequests => isFrench
      ? 'Trop de tentatives. Réessayez plus tard.'
      : 'Too many attempts. Try again later.';
  String get authGenericError => isFrench
      ? 'Une erreur est survenue. Veuillez réessayer.'
      : 'Something went wrong. Please try again.';
  String get authEmailInUse => isFrench
      ? 'Cette adresse email est déjà utilisée.'
      : 'This email is already in use.';
  String get authWeakPassword => isFrench
      ? 'Le mot de passe est trop faible.'
      : 'Password is too weak.';
  String get registerFailed => isFrench
      ? 'Impossible de créer le compte. Veuillez réessayer.'
      : 'Could not create the account. Please try again.';

  // —— Chats / groups ——
  String get addContact =>
      isFrench ? 'Ajouter un contact' : 'Add a contact';
  String get createGroup =>
      isFrench ? 'Créer un groupe' : 'Create a group';
  String get createGroupButton =>
      isFrench ? 'Créer le groupe' : 'Create group';
  String get newChat =>
      isFrench ? 'Nouvelle discussion' : 'New chat';
  String get emptyChatsTitle =>
      isFrench ? 'Aucune discussion' : 'No conversations';
  String get emptyChatsSubtitle => isFrench
      ? 'Ajoutez un contact pour démarrer une conversation.'
      : 'Add a contact to start chatting.';
  String get noChatsFound =>
      isFrench ? 'Aucune discussion trouvée' : 'No conversations found';
  String get emptyGroupsTitle =>
      isFrench ? 'Aucun groupe' : 'No groups';
  String get emptyGroupsSubtitle => isFrench
      ? 'Créez un groupe pour discuter à plusieurs.'
      : 'Create a group to chat with several people.';
  String get searchByEmail =>
      isFrench ? 'Rechercher par email' : 'Search by email';
  String get searchEmailPrompt => isFrench
      ? 'Entrez un email pour trouver un membre.'
      : 'Enter an email to find a member.';
  String get startChat =>
      isFrench ? 'Démarrer une discussion' : 'Start a chat';
  String get groupNameLabel =>
      isFrench ? 'Nom du groupe' : 'Group name';
  String get groupNameHint =>
      isFrench ? 'Entrer le nom du groupe' : 'Enter group name';
  String get membersLabel => isFrench ? 'Membres' : 'Members';
  String get addMembers =>
      isFrench ? 'Ajouter des membres' : 'Add members';
  String get noMembersSelected =>
      isFrench ? 'Aucun membre sélectionné' : 'No members selected';
  String get groupMinMembers => isFrench
      ? 'Ajoutez au moins 2 membres pour un groupe.'
      : 'Add at least 2 members for a group.';
  String noUsersFound(String query) => isFrench
      ? 'Aucun utilisateur trouvé pour « $query »'
      : 'No users found for "$query"';
  String participantsCount(int count) => isFrench
      ? '$count participants'
      : '$count participants';

  // —— Conversation ——
  String get messagesTitle => isFrench ? 'Message' : 'Message';
  String get emptyChatPrompt => isFrench
      ? 'Envoyez le premier message'
      : 'Send the first message';
  String get messageHint =>
      isFrench ? 'Écrire un message...' : 'Type a message...';
  String get attachments =>
      isFrench ? 'Pièces jointes' : 'Attachments';
  String get attachCamera => isFrench ? 'Caméra' : 'Camera';
  String get attachRecord =>
      isFrench ? 'Enregistrer' : 'Record';
  String get attachContact => isFrench ? 'Contact' : 'Contact';
  String get attachGallery => isFrench ? 'Galerie' : 'Gallery';
  String get attachLocation =>
      isFrench ? 'Ma position' : 'My Location';
  String get attachDocument =>
      isFrench ? 'Document' : 'Document';
  String get voiceMessage =>
      isFrench ? 'Message vocal' : 'Voice message';
  String get voiceTapToSend => isFrench
      ? 'Appuie à nouveau pour envoyer'
      : 'Tap again to send';
  String get voiceTapToRecord => isFrench
      ? 'Appuie sur le micro pour enregistrer'
      : 'Tap the mic to record';
  String get voiceTooShort => isFrench
      ? 'Enregistrement trop court.'
      : 'Recording too short.';
  String get micPermissionRequired => isFrench
      ? 'Autorise le micro pour enregistrer.'
      : 'Allow microphone access to record.';
  String get micUnavailable =>
      isFrench ? 'Micro indisponible.' : 'Microphone unavailable.';
  String get micPluginMissing => isFrench
      ? 'Plugin micro non chargé — arrête l’app et relance flutter run.'
      : 'Mic plugin not loaded — stop the app and run flutter run again.';
  String get imageUnavailable =>
      isFrench ? 'Image indisponible' : 'Image unavailable';
  String get pickFromGallery => isFrench
      ? 'Choisir depuis la galerie'
      : 'Choose from gallery';
  String get takePhoto =>
      isFrench ? 'Prendre une photo' : 'Take a photo';

  // —— Profile ——
  String get noUserLoggedIn => isFrench
      ? 'Aucun utilisateur connecté'
      : 'No user signed in';
  String get noBioYet => isFrench
      ? 'Aucune bio pour le moment.'
      : 'No bio yet.';
  String get defaultMemberTitle => 'Membre DevCommunity';
  String get statusOnline => isFrench ? 'En ligne' : 'Online';
  String get statusOffline => isFrench ? 'Hors ligne' : 'Offline';
  String get labelUsername => isFrench ? 'Pseudo' : 'Username';
  String get labelEmail => 'Email';
  String get labelTitle => isFrench ? 'Titre' : 'Title';
  String get labelBio => 'Bio';
  String get labelStatus => isFrench ? 'Statut' : 'Status';
  String get labelMemberSince =>
      isFrench ? 'Membre depuis' : 'Member since';
  String get labelChats =>
      isFrench ? 'Discussions' : 'Chats';
  String get editProfile =>
      isFrench ? 'Modifier mon profil' : 'Edit my profile';
  String get editProfileTitle =>
      isFrench ? 'Modifier le profil' : 'Edit profile';
  String get fieldName => isFrench ? 'Nom' : 'Name';
  String get fieldTitle => isFrench ? 'Titre' : 'Title';
  String get fieldBio => 'Bio';
  String get fieldEmail => 'Email';
  String get nameRequired =>
      isFrench ? 'Le nom est obligatoire.' : 'Name is required.';
  String get profileUpdated =>
      isFrench ? 'Profil mis à jour.' : 'Profile updated.';
  String get avatarUpdated => isFrench
      ? 'Photo de profil mise à jour.'
      : 'Profile photo updated.';
  String get profileUpdateFailed => isFrench
      ? 'Échec de la mise à jour'
      : 'Update failed';

  String languageLabel(Locale value) =>
      value.languageCode == 'fr' ? french : english;

  String monthShort(int month) {
    const fr = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    const en = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final list = isFrench ? fr : en;
    return list[month - 1];
  }
}
