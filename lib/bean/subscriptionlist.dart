class subscriptionlist{

  dynamic plan_id;
  dynamic plans;
  dynamic days;
  dynamic description;
  dynamic amount;

  subscriptionlist(this.plan_id, this.plans, this.days, this.description,
      this.amount);

  factory subscriptionlist.fromJson(dynamic json){
    return subscriptionlist(json['plan_id'], json['plans'], json['days'], json['description'], json['amount']);
  }

  @override
  String toString() {
    return 'subscriptionlist{plan_id: $plan_id, plans: $plans, days: $days, description: $description, amount: $amount}';
  }
}

