import 'package:effulgence26_mobile_app/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../cubit/edit_profile_state.dart';

class UserProfileEditPage extends StatefulWidget {
  const UserProfileEditPage({super.key});

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  @override
  void initState() {
    super.initState();
    context.read<EditProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bgPrimary,

        body: BlocConsumer<EditProfileCubit, EditProfileState>(
            listener: (context, state) {
              if(state is ProfileError){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
                context.pop();
              }
              if(state is EditProfileRequestSuccessful){

              }
            }, builder: (context, state) {
              if(state is ProfileLoaded) {
                return _buildProfileContent(context, state.profile);
              }else{
                return Container();
              }
        }
        )
    );
  }
}

Widget _buildProfileContent(BuildContext context, UserProfileEntity profile) {
  return GestureDetector(
    onTap: (){
      context.read<EditProfileCubit>().updateProfile(name: "wow");
    },
      child: Column(children: [

      ],)
  );
}