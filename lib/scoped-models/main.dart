import 'package:scoped_model/scoped_model.dart';

import './connected_services.dart';

class MainModel extends Model
    with ConnectedServicesModel, UserModel, UtilityModel {}
