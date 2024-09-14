import 'package:flutter/material.dart';
import 'package:flutter_app_chat/model/message_model.dart';
import 'package:flutter_app_chat/utilities/global_methods.dart';

class StackedReactionsWidget extends StatelessWidget {
  const StackedReactionsWidget({
    super.key,
    required this.message,
    required this.size,
    required this.onTap,
  });

  final MessageModel message;
  final double size;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    //get the reaction from the list
    final messageReactions =
        message.reactions.map((e) => e.split('=')[1]).toList();

    //If reaction are greater than 5, get the first 5 reactions
    final reactionToShow = messageReactions.length > 5
        ? messageReactions.sublist(0, 5)
        : messageReactions;

    //remaining reaction
    final remainingReactions = messageReactions.length - reactionToShow.length;
    final allReactions = reactionToShow
        .asMap()
        .map((index, reaction) {
          final value = Container(
            margin: EdgeInsets.only(left: index * 20),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipOval(
              child: Text(
                reaction,
                style: TextStyle(fontSize: size),
              ),
            ),
          );
          return MapEntry(index, value);
        })
        .values
        .toList();
    return GestureDetector(
      onTap: onTap(),
      child: Row(
        children: [
          Stack(
            children: allReactions,
          ),

          // show this if reaction more than 5
          if (remainingReactions > 0) ...[
            Positioned(
              bottom: 5,
              right: 50,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      '+$remainingReactions',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
