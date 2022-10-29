import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_app/auth/auth_error.dart';
import 'package:firebase_app/bloc/app_event.dart';
import 'package:firebase_app/bloc/app_state.dart';
import 'package:firebase_app/utils/upload_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(
    const AppStateLoggedOut(isLoading: false),
  ){

    on<AppEventGoToRegistration>((event,emit) {
      emit(const AppStateIsInRegistrationView(isLoading: false));
    });
    on<AppEventLogIn>((event,emit) async{
      emit(const AppStateLoggedOut(isLoading: true));
      //log the user in
     try{
       final email = event.email;
       final password = event.password;
       final userCredential = await FirebaseAuth
           .instance.signInWithEmailAndPassword(
           email: email,
           password: password);
       final user = userCredential.user!;
       final images= await _getImages(user.uid);
       emit(AppStateLoggedIn(isLoading: false, user: user, images: images));
     } on FirebaseAuthException catch(e){
       emit(AppStateLoggedOut(isLoading: false, authError: AuthError.from(e)));
     }

    });

    on<AppEventGoToLogin>((event,emit)  {
      emit(AppStateLoggedOut(isLoading: false));
    });


    on<AppEventRegister>((event,emit) async{
      emit(
        const AppStateIsInRegistrationView(isLoading: true)
      );
      final email = event.email;
      final password= event.password;
      try{
        final credentials =
        await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email,
              password: password,
          );
        emit(AppStateLoggedIn(isLoading: false, user: credentials.user!, images: const []));
      } on FirebaseAuthException catch(e) {
        emit(AppStateIsInRegistrationView(isLoading: false,authError: AuthError.from(e)),);
      }
    });


    on<AppEventInitialize>((event, emit) async{
      //get the current user
      final user = FirebaseAuth.instance.currentUser;
      if(user == null){
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
      }else{
        //go grab the users uploaded images
        final images = await _getImages(user.uid);
        emit(AppStateLoggedIn(isLoading: false, user: user, images: images));
      }
    });
    //log out event
    on<AppEventLogOut>((event,emit) async{
      emit(
        const AppStateLoggedOut(isLoading: true,),
      );
      await FirebaseAuth.instance.signOut();
      emit(const AppStateLoggedOut(isLoading: false));

    });
    //handle delete account
    on<AppEventDeleteAccount>(
        (event, emit) async{
          final user = FirebaseAuth.instance.currentUser;
          if(user ==null){
            emit(
              const AppStateLoggedOut(isLoading: false,),
            );
            return;
          }
          emit(
              AppStateLoggedIn(
                  isLoading: true,
                  user: user,
                  images: state.images ?? [])
          );
          try {
            final folderContents = await FirebaseStorage.instance.ref(user.uid).listAll();
            for (final item in folderContents.items){
              await item.delete().catchError((_) {});
            }
            await FirebaseStorage
            .instance
            .ref(user.uid)
            .delete()
            .catchError((_){});
            //delete the user
            await user.delete();
            //sign the user out
            await FirebaseAuth.instance.signOut();
            //log the user out of the ui
            emit(const AppStateLoggedOut(isLoading: false));

          } on FirebaseAuthException catch (e){
            emit(
                AppStateLoggedIn(
                    isLoading: false,
                    user: user,
                    images: state.images ?? [],
                authError: AuthError.from(e),),
            );

          } on FirebaseException{
            emit(
              const AppStateLoggedOut(isLoading: false,),
            );
          }
        },
    );

    on<AppEventUploadImage>((event,emit) async {
      final user = state.user;
      if(user == null){
        emit(
          const AppStateLoggedOut(isLoading: false,),
        );
        return;
      }
      emit(
        AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [])
      );
      final file = File(event.filePathToUpload);
      await uploadImage(
        file: file,
        userId: user.uid
      );
      final images = await _getImages(user.uid);
      emit(
        AppStateLoggedIn(
            isLoading: false,
            user: user,
            images: images),
      );
    }
    );
  }


  Future<Iterable<Reference>> _getImages(String userId) =>
      FirebaseStorage.instance
      .ref(userId)
      .list()
      .then((listResult) => listResult.items);
}