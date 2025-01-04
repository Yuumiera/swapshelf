import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PastExchangesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Past Exchanges',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(child: Text('Please login to view exchanges')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Past Exchanges',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exchanges')
            .where('status', whereIn: ['accepted', 'completed']).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Stream error: ${snapshot.error}');
            return Center(
                child: Text('An error occurred. Please try again later.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final exchanges = snapshot.data?.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['requesterId'] == user.uid ||
                    data['ownerId'] == user.uid;
              }).toList() ??
              [];

          if (exchanges.isEmpty) {
            return Center(child: Text('No past exchanges found'));
          }

          // Tarihe göre sırala
          exchanges.sort((a, b) {
            final aTimestamp =
                (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            final bTimestamp =
                (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            if (aTimestamp == null || bTimestamp == null) return 0;
            return bTimestamp.compareTo(aTimestamp);
          });

          return ListView.builder(
            itemCount: exchanges.length,
            itemBuilder: (context, index) {
              final exchange = exchanges[index].data() as Map<String, dynamic>;
              final status = exchange['status'] as String;
              final isRequester = exchange['requesterId'] == user.uid;

              Color statusColor =
                  status == 'accepted' ? Colors.green : Colors.blue;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    exchange['bookTitle'] ?? 'Unknown Book',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Author: ${exchange['bookAuthor'] ?? 'Unknown Author'}'),
                      if (isRequester)
                        Text('Owner: ${exchange['ownerName']}')
                      else
                        Text('Requested by: ${exchange['requesterName']}'),
                      Text(
                          'Category: ${exchange['category'] ?? 'Unknown Category'}'),
                      Text(
                          'Condition: ${exchange['condition'] ?? 'Unknown Condition'}'),
                      Row(
                        children: [
                          Text('Status: '),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _completeExchange(
      BuildContext context, String exchangeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('exchanges')
          .doc(exchangeId)
          .update({'status': 'completed'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exchange marked as completed')),
      );
    } catch (e) {
      print('Error completing exchange: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete exchange')),
      );
    }
  }
}
