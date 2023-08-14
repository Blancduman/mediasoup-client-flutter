import 'dart:async';

abstract class FlexTask {
  final String? id;
  final Function execFun;
  final Function? callbackFun;
  final Function? errorCallbackFun;
  final Object? argument;
  final String? message;

  FlexTask({
    this.id,
    required this.execFun,
    this.argument,
    this.callbackFun,
    this.errorCallbackFun,
    this.message,
  });
}

class FlexTaskAdd extends FlexTask {
  FlexTaskAdd({
    String? id,
    required Function execFun,
    Object? argument,
    Function? callbackFun,
    Function? errorCallbackFun,
    String? message,
  }) : super(
          id: id,
          execFun: execFun,
          argument: argument,
          callbackFun: callbackFun,
          errorCallbackFun: errorCallbackFun,
          message: message,
        );
}

class FlexTaskRemove extends FlexTask {
  FlexTaskRemove({
    String? id,
    required Function execFun,
    Object? argument,
    Function? callbackFun,
    Function? errorCallbackFun,
    String? message,
  }) : super(
          id: id,
          execFun: execFun,
          argument: argument,
          callbackFun: callbackFun,
          errorCallbackFun: errorCallbackFun,
          message: message,
        );
}

class FlexQueueStream {
  final List<FlexTask> tasks = <FlexTask>[];
  final StreamController<FlexTask> controller = StreamController<FlexTask>();

  FlexQueueStream() {
    init();
  }

  init() async {
    await for (final _ in controller.stream) {
      if (tasks.isEmpty) {
        continue;
      }

      final job = tasks.removeAt(0);
      await runTask(job);
    }
  }

  Future<void> runTask(task) async {
    try {
      if (task.argument == null) {
        final result = await task.execFun();
        task.callbackFun?.call(result);
      } else {
        final result = await task.execFun(task.argument);
        task.callbackFun?.call(result);
      }
    } catch (error, st) {
      print(error);
      print(st);
      task.errorCallbackFun?.call(error);
    }
  }

  void addTask(FlexTask task) async {
    if (task is FlexTaskRemove) {
      final index = tasks.indexWhere((element) => element.id == task.id);
      if (index != -1) {
        tasks.removeAt(index);
        return;
      }
    }

    tasks.add(task);
    controller.sink.add(task);
  }

  Future<void> close() async {
    await controller.close();
  }
}
