import 'package:carretera/core/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicia sesión con correo y contraseña
  Future<User?> signin(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Registra un nuevo usuario y guarda sus datos en Firestore
  Future<User?> signup(String email, String password, String nombre) async {
    try {
      // Crea un usuario en Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtén el UID generado por Firebase
      String? uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception("El UID del usuario no está disponible.");
      }

      // Crea el objeto Usuario con el UID
      Usuario usuario = Usuario(
        id: uid, // Asigna el UID al campo id
        email: email,
        nivel: "cliente",
        nombre: nombre,
        fechaCreacion: DateTime.now(),
      );

      // Guarda el usuario en Firestore utilizando su UID
      await _firestore.collection('usuarios').doc(uid).set(usuario.toJson());

      return userCredential.user; // Retorna el usuario autenticado
    } catch (e) {
      rethrow; // Propaga el error si ocurre
    }
  }

  /// Obtiene el usuario autenticado actual
  Future<Usuario?> getAuthenticatedUser() async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        return Usuario.fromJson(
          userDoc.data() as Map<String, dynamic>,
          id: firebaseUser.uid, // Incluye el UID del usuario
        );
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cierra sesión del usuario actual
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
