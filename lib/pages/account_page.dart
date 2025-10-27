import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:buildausermanagement/components/avatar.dart';
import 'package:buildausermanagement/main.dart';
import 'package:buildausermanagement/pages/login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _avatarUrl;
  var _loading = true;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });
    
    try {
      final userId = supabase.auth.currentSession!.user.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      // Si hay datos guardados, usarlos
      _usernameController.text = (data['username'] ?? '') as String;
      _websiteController.text = (data['website'] ?? '') as String;
      _avatarUrl = (data['avatar_url'] ?? '') as String;
      
      // Si no hay datos, usar los por defecto
      if (_usernameController.text.isEmpty) {
        _usernameController.text = 'dshukertjr';
      }
      if (_websiteController.text.isEmpty) {
        _websiteController.text = 'supabase.io';
      }
      if (_avatarUrl == null || _avatarUrl!.isEmpty) {
        _avatarUrl = 'https://i.pravatar.cc/300?img=3';
      }
      
    } on PostgrestException catch (error) {
      // Si no existe el perfil, crear uno con datos por defecto
      if (error.code == 'PGRST116') {
        final userId = supabase.auth.currentSession!.user.id;
        _usernameController.text = 'dshukertjr';
        _websiteController.text = 'supabase.io';
        _avatarUrl = 'https://i.pravatar.cc/300?img=3';
        
        try {
          await supabase.from('profiles').insert({
            'id': userId,
            'username': _usernameController.text,
            'website': _websiteController.text,
            'avatar_url': _avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (insertError) {
          if (mounted) context.showSnackBar('Error creating default profile', isError: true);
        }
      } else {
        if (mounted) context.showSnackBar(error.message, isError: true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final userName = _usernameController.text.trim();
    final website = _websiteController.text.trim();
    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'username': userName,
      'website': website,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) context.showSnackBar('Successfully updated profile!');
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    }
  }

  /// Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
      print('🔄 _onUpload called with URL: $imageUrl');

      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'avatar_url': imageUrl,
      });

      print('✅ Database updated successfully');

      // Actualizar el estado local
      setState(() {
        _avatarUrl = imageUrl;
      });

      print('✅ Local state updated with new avatar URL');

      if (mounted) {
        context.showSnackBar('¡Imagen de perfil actualizada! 🎉');
      }
    } on PostgrestException catch (error) {
      print('❌ Database error: ${error.message}');
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      print('❌ Unexpected error in _onUpload: $error');
      if (mounted) {
        context.showSnackBar(
          'Error al actualizar imagen de perfil',
          isError: true,
        );
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          Avatar(imageUrl: _avatarUrl, onUpload: _onUpload),
          const SizedBox(height: 18),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'User Name'),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(labelText: 'Website'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _loading ? null : _updateProfile,
            child: Text(_loading ? 'Saving...' : 'Update'),
          ),
          const SizedBox(height: 18),
          TextButton(onPressed: _signOut, child: const Text('Sign Out')),
        ],
      ),
    );
  }
}
