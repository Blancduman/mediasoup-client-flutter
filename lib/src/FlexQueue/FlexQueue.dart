abstract class FlexTask {
  final String id;
  final Function execFun;
  final Function callbackFun;
  final Function errorCallbackFun;
  final Object argument;
  final String message;

  FlexTask({
    this.id,
    this.execFun,
    this.argument,
    this.callbackFun,
    this.errorCallbackFun,
    this.message,
  });
}

class FlexTaskAdd extends FlexTask {
  FlexTaskAdd({
    String id,
    Function execFun,
    Object argument,
    Function callbackFun,
    Function errorCallbackFun,
    String message,
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
    String id,
    Function execFun,
    Object argument,
    Function callbackFun,
    Function errorCallbackFun,
    String message,
  }) : super(
          id: id,
          execFun: execFun,
          argument: argument,
          callbackFun: callbackFun,
          errorCallbackFun: errorCallbackFun,
          message: message,
        );
}

class FlexQueue {
  bool isBusy = false;
  final List<FlexTask> taskQueue = [];

  void addTask(FlexTask task) async {
    if (task is FlexTaskRemove) {
      int index = taskQueue.indexWhere((FlexTask qTask) => qTask.id == task.id);
      if (index != -1) {
        print(task?.message);
        taskQueue.removeAt(index);
        return;
      } else {
        taskQueue.add(task);
        _runTask();
      }
    } else if (task is FlexTaskAdd) {
      taskQueue.add(task);
      _runTask();
    }
  }

  Future<void> _runTask() async {
    if (!isBusy) {
      if (taskQueue.isNotEmpty) {
        isBusy = true;
        FlexTask task = taskQueue.removeAt(0);
        print(task?.message);
        try {
          if (task.argument == null) {
            task?.callbackFun((await task.execFun()));
          } else {
            task?.callbackFun((await task.execFun(task.argument)));
          }
        } catch (error) {
          task?.errorCallbackFun(error);
        }
        isBusy = false;
        _runTask();
      }
    }
  }
}
