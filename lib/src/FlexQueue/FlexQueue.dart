
abstract class FlexTask {
  final String id;
  final Function execFun;
  final Function callbackFun;
  final Object argument;

  FlexTask({this.id, this.execFun, this.argument, this.callbackFun,});
}

class FlexTaskAdd extends FlexTask {
  FlexTaskAdd({String id, Function execFun, Object argument, Function callbackFun}) : super(id: id, execFun: execFun, argument: argument, callbackFun: callbackFun,);
}

class FlexTaskRemove extends FlexTask {

  FlexTaskRemove({String id, Function execFun, Object argument, Function callbackFun}) : super(id: id, execFun: execFun, argument: argument, callbackFun: callbackFun,);
}

class FlexQueue {
  bool isBusy = false;
  final List<FlexTask> taskQueue = [];

  void addTask(FlexTask task) async {
    if (task is FlexTaskRemove) {
      int index = taskQueue.indexWhere((FlexTask qTask) => qTask.id == task.id);
      if (index != -1) {
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
        task?.callbackFun((await task.execFun(task.argument)));
        isBusy = false;
        _runTask();
      }
    }
  }
}