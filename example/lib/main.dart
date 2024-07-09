import 'package:flutter/material.dart';
import 'package:tortuga_grouped_dropdown/tortuga_grouped_dropdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MyEntity? _payerEntity;
  MyAccount? _payerAccount;
  MyEntity? _recipientEntity;
  String? _defaultStringValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payer',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 300,
                      child: TortugaGroupedDropdown<MyEntity, MyAccount>(
                        items: entities
                            .map(
                              (entity) => DropdownValueWithChildren(
                                value: entity,
                                children: entity.accounts,
                              ),
                            )
                            .toList(),
                        hint: const Text('Entities/Accounts'),
                        onChanged: (entity) {
                          if (entity == null) return;

                          setState(() {
                            _payerEntity = entity.value;
                            _payerAccount = entity.chosenChild;
                          });
                        },
                        value: DropdownValueWithChildren(
                          value: _payerEntity,
                          children: _payerEntity?.accounts,
                          chosenChild: _payerAccount,
                        ),
                        childBuilder: (account) => ListTile(
                          title: Text(account.title),
                          subtitle:
                              Text('${account.currency} | ${account.number}'),
                        ),
                        itemBuilder: (entity, isSelected) => EntityTile(
                          entity: entity.value!,
                          isSelected: isSelected,
                        ),
                        builder: (entity) => EntityTile(
                          entity: entity.value!,
                          entityAccount: entity.chosenChild,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 250),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text(
                //       'Recipient',
                //       style: Theme.of(context).textTheme.titleLarge,
                //     ),
                //     const SizedBox(height: 10),
                //     TortugaGroupedDropdown<MyEntity>(
                //       hint: const Text('Entities/Accounts'),
                //       items: entities,
                //       onChanged: (entity) {
                //         setState(() {
                //           _recipientEntity = entity;
                //         });
                //       },
                //       value: _recipientEntity,
                //       itemBuilder: (entity, isSelected) => EntityTile(
                //         entity: entity,
                //         isSelected: isSelected,
                //       ),
                //       builder: (entity) => EntityTile(
                //         entity: entity,
                //         entityAccount: entity.accounts?.last,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 50),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text(
                //       'Default dropdown',
                //       style: Theme.of(context).textTheme.titleLarge,
                //     ),
                //     const SizedBox(height: 10),
                //     TortugaGroupedDropdown<String>(
                //       items: const ['Hello', 'World', 'Amigo', 'Dima'],
                //       value: _defaultStringValue,
                //       onChanged: (value) {
                //         setState(() {
                //           _defaultStringValue = value;
                //         });
                //       },
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EntityTile extends StatelessWidget {
  const EntityTile({
    required this.entity,
    this.isSelected = false,
    this.entityAccount,
    super.key,
  });

  final bool isSelected;
  final MyEntity entity;
  final MyAccount? entityAccount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 14,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: entityAccount == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Text(
              entity.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 16),
            ),
            if (entityAccount != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entityAccount!.currency} | '
                    '${entityAccount!.title}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          entityAccount!.number,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const InkWell(
                        child: Icon(Icons.copy_rounded, size: 20),
                      ),
                    ],
                  )
                ],
              )
            else
              Text(
                entity.email!,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontSize: 14),
              ),
          ],
        )
      ],
    );
  }
}

const entities = [
  MyEntity(
    id: 5,
    title: 'Dudunov Dmitry',
    email: 'dydynovdima6@gmail.com',
    accounts: [
      MyAccount(
        id: 1,
        number: 'T913821TJKASFDJAH',
        title: 'Tether wallet',
        currency: 'USDT',
      ),
      MyAccount(
        id: 2,
        number: '220032103123',
        title: 'Tinkoff',
        currency: 'RUB',
      ),
    ],
  ),
  MyEntity(
    id: 2,
    title: 'Atlantida',
    email: 'atlantida@gmail.com',
    accounts: [
      MyAccount(
        id: 3,
        number: '87ghjnhy6tghjnbgt5',
        title: 'Crypto Wallet',
        currency: 'USDT',
      ),
      MyAccount(
        id: 4,
        number: '678ijhgfr56yhbfd',
        title: 'Binance',
        currency: 'USD',
      ),
    ],
  ),
  MyEntity(
    id: 3,
    title: 'Offerstore',
    email: 'offerstore@gmail.com',
  ),
];

class MyEntity {
  const MyEntity({
    required this.id,
    required this.title,
    this.email,
    this.accounts,
  });

  final int id;
  final String title;
  final String? email;
  final List<MyAccount>? accounts;
}

class MyAccount {
  const MyAccount({
    required this.id,
    required this.number,
    required this.currency,
    required this.title,
  });

  final int id;
  final String title;
  final String currency;
  final String number;
}
