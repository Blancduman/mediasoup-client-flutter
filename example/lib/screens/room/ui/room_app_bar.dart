import 'package:example/features/signaling/room_client_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example/features/room/bloc/room_bloc.dart';

class RoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool display;
  const RoomAppBar({Key? key, required this.display}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: display ? 1.0 : 0.0,
          child: AppBar(
            elevation: 5,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            title: Builder(
              builder: (context) {
                String url =
                context.select((RoomBloc bloc) => bloc.state.url);
                return Text(
                  'Room id: ${Uri.parse(url).queryParameters['roomId'] ?? Uri.parse(url).queryParameters['roomid']}',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  String url = context.read<RoomBloc>().state.url;
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Room link copied to clipboard'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(Icons.copy, color: Colors.black,),
              ),
            ],
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black,),
              onPressed: () {
                context.read<RoomClientRepository>().close();
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
