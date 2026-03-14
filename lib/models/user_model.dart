class UserModel {
  final String userId;
  final String name;
  final int ecoCoins;
  final int rank;
  final List<String> scanHistory;
  final List<String> recyclingHistory;

  UserModel({
    required this.userId,
    required this.name,
    required this.ecoCoins,
    required this.rank,
    required this.scanHistory,
    required this.recyclingHistory,
  });
}
