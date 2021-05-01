const String getDonationsRequest = """
  subscription {
    temp_money_donations(order_by: {donation_date: desc}) {
      donator
      id
      value
      donation_date
    }
  }
""";

const String getDonationLoggedInRequest = """
  subscription{ 
    temp_money_donations(order_by: {donation_date: desc}) {
      created_at
      donator
      id
      updated_at
      value
      donation_date
      donator_hidden
    }
  }
""";

const String insertDonationRequest = r"""
mutation ($donator: String, $donator_hidden: String, $value: Int!, $donation_date: timestamp!) {
  insert_temp_money_donations(objects: {donation_date: $donation_date, donator: $donator, donator_hidden: $donator_hidden, value: $value}) {
    returning {
      id
    }
  }
}
""";

const String deleteDonationRequest = r"""
mutation ($id: Int!) {
  delete_temp_money_donations_by_pk(id: $id) {
    id
  }
}
""";

const String updateDonationRequest = r"""
mutation ($id: Int!, $donator: String!, $donator_hidden: String, $value: Int!, $donation_date: timestamp!) {
  update_temp_money_donations_by_pk(pk_columns: {id: $id}, _set: {donator: $donator, donator_hidden: $donator_hidden, value: $value, donation_date: $donation_date}) {
    id
  }
}
""";

const String getDonationRequestById = r"""
query ($id: Int!) {
  temp_money_donations_by_pk(id: $id) {
    donator
    id
    value
    donation_date
  }
}
""";

const String getUsagesRequest = """
  subscription {
    temp_money_used_for(order_by: {usage_date: desc, created_at:asc}) {
      created_at
      id
      storage_image_name
      updated_at
      usage
      value
      usage_date
      receivers_name 
      storage_image_name_person
    }
  }
""";

const String getUsageLoggedInRequest = """
  subscription {
    temp_money_used_for(order_by: {usage_date: desc, created_at:asc}) {
      id
      created_at
      storage_image_name
      storage_image_name_person
      updated_at
      usage
      value
      usage_date
      receivers_name 
      receiver_hidden_name
    }
  }
""";

const String insertUsageRequest = r"""
mutation ($receiver_hidden_name: String, $receivers_name: String, $storage_image_name: String, $storage_image_name_person: String, $usage: String!, $usage_date: timestamp, $value: Int!) {
  insert_temp_money_used_for_one(object: {receiver_hidden_name: $receiver_hidden_name, receivers_name: $receivers_name, storage_image_name: $storage_image_name, storage_image_name_person: $storage_image_name_person, usage: $usage, usage_date: $usage_date, value: $value}) {
    id
  }
}
""";

const String deleteUsageRequest = r"""
mutation ($id: Int!) {
  delete_temp_money_used_for_by_pk(id: $id) {
    id
  }
}
""";

const String updateUsageRequest = r"""
mutation ($id: Int!, $receiver_hidden_name: String, $receivers_name: String, $storage_image_name: String, $storage_image_name_person: String, $usage: String!, $usage_date: timestamp, $value: Int!) {
  update_temp_money_used_for_by_pk(pk_columns: {id: $id}, _set: {receiver_hidden_name: $receiver_hidden_name, receivers_name: $receivers_name, storage_image_name: $storage_image_name, storage_image_name_person: $storage_image_name_person, usage: $usage, value: $value, usage_date: $usage_date}) {
    id
  }
}
""";

const String getUsageRequestById = r"""
query ($id: Int!) {
  temp_money_used_for_by_pk(id: $id) {
      id
      created_at
      storage_image_name
      storage_image_name_person
      updated_at
      usage
      value
      usage_date
      receivers_name 
      receiver_hidden_name
  }
}
""";

// const String getUsage = """
//   subscription {
//     temp_money_used_for(order_by: {usage_date: desc, created_at:asc}) {
//       created_at
//       id
//       storage_image_name
//       updated_at
//       usage
//       value
//       usage_date
//       receivers_name 
//       storage_image_name_person
//     }
//   }
// """;
