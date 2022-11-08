class Env{
  String baseURL = "https://tht-api.nutech-integrasi.app";

  Future<String> postRegist() async {
    return "$baseURL/registration";
  }
  Future<String> postLogin() async {
    return "$baseURL/login";
  }
  Future<String> postUpdateProfile() async {
    return "$baseURL/updateProfile";
  }
  Future<String> getProfile() async {
    return "$baseURL/getProfile";
  }
  Future<String> postTopup() async {
    return "$baseURL/topup";
  }
  Future<String> postTransfer() async {
    return "$baseURL/transfer";
  }
  Future<String> getHistory() async {
    return "$baseURL/transactionHistory";
  }
  Future<String> getBalance() async {
    return "$baseURL/balance";
  }

}