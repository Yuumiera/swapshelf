import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExchangeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Center(child: Text('Please login to view exchanges'));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: TabBar(
              isScrollable: false,
              tabs: [
                Tab(
                  height: 35,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'My Requests',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Tab(
                  height: 35,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Incoming Requests',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelPadding: EdgeInsets.zero,
              indicatorWeight: 2,
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
        body: TabBarView(
          children: [
            _buildMyRequests(currentUser),
            _buildIncomingRequests(currentUser),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRequests(User currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('exchanges')
          .where('requesterId', isEqualTo: currentUser.uid)
          .where('status',
              whereIn: ['pending', 'accepted', 'rejected']).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('An error occurred'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Center(child: Text('No active exchange requests'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            final status = request['status'] as String;

            Color statusColor;
            switch (status) {
              case 'pending':
                statusColor = Colors.orange;
                break;
              case 'accepted':
                statusColor = Colors.green;
                break;
              case 'rejected':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.grey;
            }

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  request['bookTitle'] ?? 'Unknown Book',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Author: ${request['bookAuthor'] ?? 'Unknown Author'}'),
                    Text('Owner: ${request['ownerName'] ?? 'Unknown Owner'}'),
                    Text(
                        'Category: ${request['category'] ?? 'Unknown Category'}'),
                    Text(
                        'Condition: ${request['condition'] ?? 'Unknown Condition'}'),
                    Row(
                      children: [
                        Text('Status: '),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                trailing: status == 'pending'
                    ? IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () =>
                            _showCancelDialog(context, requests[index].id),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIncomingRequests(User currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('exchanges')
          .where('ownerId', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('An error occurred'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Center(child: Text('No incoming exchange requests'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            final status = request['status'] as String;

            Color statusColor;
            switch (status) {
              case 'pending':
                statusColor = Colors.orange;
                break;
              case 'accepted':
                statusColor = Colors.green;
                break;
              case 'rejected':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.grey;
            }

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  request['bookTitle'] ?? 'Unknown Book',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Author: ${request['bookAuthor'] ?? 'Unknown Author'}'),
                    FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('users')
                          .doc(request['requesterId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        String requesterName =
                            request['requesterName'] ?? 'Unknown User';
                        if (userSnapshot.hasData && userSnapshot.data != null) {
                          final userData = userSnapshot.data!.data()
                              as Map<String, dynamic>?;
                          requesterName = userData?['name'] ??
                              request['requesterName'] ??
                              'Unknown User';
                        }
                        return Text('Requested by: $requesterName');
                      },
                    ),
                    Text(
                        'Category: ${request['category'] ?? 'Unknown Category'}'),
                    Text(
                        'Condition: ${request['condition'] ?? 'Unknown Condition'}'),
                    Row(
                      children: [
                        Text('Status: '),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                trailing: status == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _updateExchangeStatus(
                              context,
                              requests[index].id,
                              'accepted',
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _updateExchangeStatus(
                              context,
                              requests[index].id,
                              'rejected',
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Exchange Request'),
          content:
              Text('Are you sure you want to cancel this exchange request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _firestore
                      .collection('exchanges')
                      .doc(requestId)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Exchange request cancelled successfully')),
                  );
                } catch (e) {
                  print('Error cancelling exchange: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to cancel exchange request')),
                  );
                }
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateExchangeStatus(
      BuildContext context, String requestId, String newStatus) async {
    try {
      // Önce seçilen request'in kitap bilgilerini alalım
      final selectedRequest =
          await _firestore.collection('exchanges').doc(requestId).get();
      final selectedRequestData =
          selectedRequest.data() as Map<String, dynamic>;

      if (newStatus == 'accepted') {
        // Batch işlemi başlat
        WriteBatch batch = _firestore.batch();

        // Seçilen request'i kabul et
        batch.update(_firestore.collection('exchanges').doc(requestId), {
          'status': newStatus,
        });

        // Aynı kitap için olan diğer bekleyen requestleri bul ve reddet
        final otherRequests = await _firestore
            .collection('exchanges')
            .where('bookId', isEqualTo: selectedRequestData['bookId'])
            .where('status', isEqualTo: 'pending')
            .where(FieldPath.documentId, isNotEqualTo: requestId)
            .get();

        // Diğer requestleri reddet
        for (var doc in otherRequests.docs) {
          batch.update(doc.reference, {'status': 'rejected'});
        }

        // Tüm değişiklikleri uygula
        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Takas talebi kabul edildi')),
        );
      } else {
        // Sadece reddetme durumu
        await _firestore.collection('exchanges').doc(requestId).update({
          'status': newStatus,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Takas talebi reddedildi')),
        );
      }
    } catch (e) {
      print('Error updating exchange status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Takas durumu güncellenirken bir hata oluştu')),
      );
    }
  }
}
