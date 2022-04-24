import 'package:equatable/equatable.dart';

/// Paynow Configuration
class PaynowConfig extends Equatable{
  PaynowConfig({
    required this.integrationId,
    required this.integrationKey,
    required this.authEmail,
    required this.reference,

  });

  factory PaynowConfig.fromMap(map)=>PaynowConfig(
      integrationId: map['integrationId'],
      integrationKey: map['integrationKey'],
      authEmail: map['authEmail'],
      reference: map['reference']
  );

  PaynowConfig copyWith({
    String? integrationKey,
    String? integrationId,
    String? reference,
    String? authEmail
  }){
    return PaynowConfig(
        integrationId: integrationId ?? this.integrationId,
        integrationKey: integrationKey ?? this.integrationKey,
        authEmail: authEmail ?? this.authEmail,
        reference: reference ?? this.reference
    );
  }

  /// Integration ID obtained from Paynow
  final String integrationId;

  /// Integration Key obtained from Paynow
  final String integrationKey;

  /// Auth Email
  final String authEmail;

  /// Reference for current payment
  final String reference;

  @override
  // TODO: implement props
  List<Object?> get props => [
    integrationId,
    integrationKey,
    authEmail,
    reference
  ];
}