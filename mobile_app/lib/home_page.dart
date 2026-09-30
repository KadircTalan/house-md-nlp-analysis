import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController _textController =
  TextEditingController();

  String _predictedSarcasm = "-";
  String _predictedIntent = "-";
  String _predictedStage = "-";
  String _predictedEmotion = "-";

  bool _isAnalyzing = false;

  // =====================================================
  // ANALYZE
  // =====================================================

  Future<void> _analyzeText() async {

    if (_textController.text.trim().isEmpty) {
      _showError("Lütfen metin girin");
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {

      final url = Uri.parse(
        'https://blue-nlp-platform.onrender.com/predict',
      );

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "text": _textController.text.trim(),
          "userId":
          FirebaseAuth.instance.currentUser?.uid ?? "guest",
        }),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        setState(() {
          _predictedSarcasm =
              data["sarcasm"] ?? "-";

          _predictedIntent =
              data["intent"] ?? "-";

          _predictedStage =
              data["stage"] ?? "-";

          _predictedEmotion =
              data["emotion"] ?? "-";
        });

        _textController.clear();

      } else {

        _showError(
          "Sunucu hatası: ${response.statusCode}",
        );
      }

    } catch (e) {

      _showError(
        "API bağlantı hatası",
      );

      debugPrint(e.toString());

    } finally {

      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showError(String message) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      drawer: Drawer(
        backgroundColor: const Color(0xff0F172A),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 70,
                bottom: 25,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff2563EB),
                    Color(0xff1D4ED8),
                  ],
                ),
              ),

              child: Column(
                children: [

                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Geçmiş Analizler",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    user?.email ?? "Misafir",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore.instance
                    .collection("analyses")
                    .where(
                  "userId",
                  isEqualTo: user?.uid ?? "",
                )
                    .orderBy(
                  "timestamp",
                  descending: true,
                )
                    .snapshots(),

                builder: (context, snapshot) {

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Firestore hatası",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {

                    return const Center(
                      child: Text(
                        "Henüz analiz yok",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(

                    padding: const EdgeInsets.all(14),

                    itemCount: docs.length,

                    itemBuilder: (context, index) {

                      final data =
                      docs[index].data()
                      as Map<String, dynamic>;

                      final timestamp =
                      data["timestamp"];

                      DateTime? date;

                      if (timestamp != null) {
                        date = timestamp.toDate();
                      }

                      return Container(

                        margin: const EdgeInsets.only(
                          bottom: 14,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                            color:
                            Colors.white.withOpacity(0.08),
                          ),
                        ),

                        child: ExpansionTile(

                          collapsedIconColor: Colors.white,
                          iconColor: Colors.white,

                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                              Colors.blue.withOpacity(0.15),
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.analytics_rounded,
                              color: Colors.white,
                            ),
                          ),

                          title: Text(
                            data["inputText"] ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          subtitle: Text(
                            date != null
                                ? date
                                .toString()
                                .substring(0, 16)
                                : "",
                            style: TextStyle(
                              color:
                              Colors.white.withOpacity(0.6),
                            ),
                          ),

                          children: [

                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(

                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  _buildInfoRow(
                                    "Alaycılık",
                                    data["sarcasm"] ?? "-",
                                  ),

                                  const SizedBox(height: 12),

                                  _buildInfoRow(
                                    "Niyet",
                                    data["intent"] ?? "-",
                                  ),

                                  const SizedBox(height: 12),

                                  _buildInfoRow(
                                    "Aşama",
                                    data["stage"] ?? "-",
                                  ),

                                  const SizedBox(height: 12),

                                  _buildInfoRow(
                                    "Duygu",
                                    data["emotion"] ?? "-",
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    data["inputText"] ?? "",
                                    style: TextStyle(
                                      color: Colors.white
                                          .withOpacity(0.85),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff0F172A),
              Color(0xff1E3A8A),
              Color(0xff2563EB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(22),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                // =====================================================
                // TOP BAR
                // =====================================================

                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    Builder(
                      builder: (context) => GestureDetector(

                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },

                        child: Container(
                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color:
                            Colors.white.withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(18),
                          ),

                          child: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,

                      children: [

                        const Text(
                          "BLUE AI",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            letterSpacing: 2,
                          ),
                        ),

                        Text(
                          "Tıbbi NLP Analizi",
                          style: TextStyle(
                            color:
                            Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // =====================================================
                // HERO CARD
                // =====================================================

                Container(

                  width: double.infinity,
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(

                    borderRadius:
                    BorderRadius.circular(30),

                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.06),
                      ],
                    ),

                    border: Border.all(
                      color:
                      Colors.white.withOpacity(0.12),
                    ),
                  ),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                          Colors.blue.withOpacity(0.18),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.psychology_alt_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        "Yeni Analiz",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Hasta verisini analiz ederek alaycılık, niyet, aşama ve duygu tahmini oluştur.",
                        style: TextStyle(
                          color:
                          Colors.white.withOpacity(0.75),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // =====================================================
                      // TEXTFIELD
                      // =====================================================

                      Container(

                        decoration: BoxDecoration(
                          color:
                          Colors.white.withOpacity(0.08),
                          borderRadius:
                          BorderRadius.circular(24),
                          border: Border.all(
                            color:
                            Colors.white.withOpacity(0.08),
                          ),
                        ),

                        child: TextField(

                          controller: _textController,

                          maxLines: 6,

                          style: const TextStyle(
                            color: Colors.white,
                          ),

                          decoration: InputDecoration(

                            contentPadding:
                            const EdgeInsets.all(22),

                            border: InputBorder.none,

                            hintText:
                            "Hasta verisini girin...",

                            hintStyle: TextStyle(
                              color:
                              Colors.white.withOpacity(0.45),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =====================================================
                      // BUTTON
                      // =====================================================

                      SizedBox(
                        width: double.infinity,
                        height: 60,

                        child: ElevatedButton.icon(

                          onPressed:
                          _isAnalyzing
                              ? null
                              : _analyzeText,

                          icon: _isAnalyzing

                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )

                              : const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                          ),

                          label: Text(

                            _isAnalyzing
                                ? "Analiz Ediliyor..."
                                : "Analiz Et",

                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          style: ElevatedButton.styleFrom(

                            elevation: 10,

                            backgroundColor:
                            const Color(0xff3B82F6),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // =====================================================
                // RESULT SECTION
                // =====================================================

                Row(
                  children: [
                    Expanded(
                      child: _buildResultCard(
                        title: "Alaycılık",
                        value: _predictedSarcasm,
                        icon: Icons.flourescent_rounded, // Not: Tasarımsal yapıyı korumak adına genel ikon verilmiştir, dilediğin ikonu seçebilirsin.
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _buildResultCard(
                        title: "Niyet",
                        value: _predictedIntent,
                        icon: Icons.assignment_ind_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(

                  children: [

                    Expanded(
                      child: _buildResultCard(
                        title: "Aşama",
                        value: _predictedStage,
                        icon: Icons.timeline_rounded,
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: _buildResultCard(
                        title: "Duygu",
                        value: _predictedEmotion,
                        icon: Icons.psychology_alt_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// =====================================================
// RESULT CARD
// =====================================================

  Widget _buildResultCard({

    required String title,
    required String value,
    required IconData icon,

  }) {

    return Container(

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(28),

        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.14),
            Colors.white.withOpacity(0.06),
          ],
        ),

        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),

      child: Column(

        children: [

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 34,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

// =====================================================
// INFO ROW
// =====================================================

  Widget _buildInfoRow(
      String title,
      String value,
      ) {

    return Row(

      children: [

        Text(
          "$title: ",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color:
              Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }}