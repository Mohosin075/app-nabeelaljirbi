class WorkingHoursModel {
  bool? success;
  String? message;
  WorkingHoursData? data;

  WorkingHoursModel({this.success, this.message, this.data});

  WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? WorkingHoursData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class WorkingHoursData {
  List<DaySchedule>? slots;

  WorkingHoursData({this.slots});

  WorkingHoursData.fromJson(Map<String, dynamic> json) {
    if (json['slots'] != null) {
      slots = <DaySchedule>[];
      json['slots'].forEach((v) {
        slots!.add(DaySchedule.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DaySchedule {
  String? day;
  List<WorkingSlot>? slots;

  DaySchedule({this.day, this.slots});

  DaySchedule.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    if (json['slots'] != null) {
      slots = <WorkingSlot>[];
      json['slots'].forEach((v) {
        slots!.add(WorkingSlot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WorkingSlot {
  String? id;
  String? startTime;
  String? endTime;
  int? capacity;
  bool? isActive;

  WorkingSlot({
    this.id,
    this.startTime,
    this.endTime,
    this.capacity,
    this.isActive,
  });

  WorkingSlot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    capacity = json['capacity'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['capacity'] = capacity;
    data['isActive'] = isActive;
    return data;
  }
}
