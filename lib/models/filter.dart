

import 'package:timer/StateManager.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/models/user.dart';

class Filter {

  final int minGrade;
  final int maxGrade;
  final User author;
  final String sector;
  final bool ignoreCompleted;

  /// Order set by
  /// 0 = date
  /// 1 = author
  /// 2 = name
  /// 3 = grade
  final int orderBy;

  final bool ascending;

  Filter({this.ignoreCompleted = false, this.minGrade = 0, this.maxGrade = 20, this.author, this.sector, this.orderBy = 0, this.ascending = false});

  List<Rute> filter(List<Rute> rutes) {

    List<Rute> result = List<Rute>();

    for(Rute r in rutes) {
      bool accept = minGrade <= r.grade && r.grade <= maxGrade;
      if(ignoreCompleted) accept = accept && !r.hasCompleted(StateManager().loggedInUser);
      if(author != null) accept = accept && r.author == author;
      if(sector != null) accept = accept && r.sector == sector;
      if(accept) result.add(r);
    }

    int sign = ascending ? 1 : -1;
    if(orderBy==0) {
      result.sort((r1, r2) => sign * r1.date.compareTo(r2.date));
    }
    if(orderBy==1) {
      result.sort((r1, r2) => sign * r1.author.name.compareTo(r2.author.name));
    }
    if(orderBy==2) {
      result.sort((r1, r2) => sign * r1.name.compareTo(r2.name));
    }
    if(orderBy==3) {
      result.sort((r1, r2) => sign * r1.grade.compareTo(r2.grade));
    }

    return result;

  }


}