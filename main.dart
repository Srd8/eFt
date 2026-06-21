import 'package:flutter/material.dart';
import 'dart:convert';

void main() => runApp(const EFootballEpicRadarApp());

class EFootballEpicRadarApp extends StatelessWidget {
  const EFootballEpicRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eFootball Epic Radar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080C14),
        primaryColor: const Color(0xFFE5B842),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE5B842),
          secondary: Color(0xFF00FFAA),
        ),
      ),
      home: const KonamiLoginScreen(),
    );
  }
}

// ----------------------------------------------------
// 1. شاشة تسجيل الدخول باسم مستخدم كونامي (Konami ID)
// ----------------------------------------------------
class KonamiLoginScreen extends StatefulWidget {
  const KonamiLoginScreen({super.key});

  @override
  State<KonamiLoginScreen> createState() => _KonamiLoginScreenState();
}

class _KonamiLoginScreenState extends State<KonamiLoginScreen> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // محاكاة الاتصال الآمن بسيرفر كونامي للتحقق
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainDashboard(konamiUser: _usernameController.text)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // شعار التطبيق الاحترافي
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5B842), width: 3),
                    boxShadow: const [BoxShadow(color: Color(0x33E5B842), blurRadius: 20)],
                  ),
                  child: const Text('🎯', style: TextStyle(fontSize: 50)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'eFOOTBALL EPIC RADAR',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text('تتبع كروت الإيبك الحية في السيرفر فور نزولها', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 40),
                
                // حقل إدخال اسم مستخدم كونامي
                TextFormField(
                  controller: _usernameController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'أدخل اسم مستخدم كونامي (KONAMI ID)',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF121824),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF00FFAA)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF00FFAA), width: 1.5),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال اسم المستخدم للمتابعة' : null,
                ),
                const SizedBox(height: 24),
                
                // زر تسجيل الدخول
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5B842),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black) 
                      : const Text('دخول السيرفر الآمن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 2. الشاشة الرئيسية للتطبيق ولوحة التحكم بالبيانات الحية
// ----------------------------------------------------
class MainDashboard extends StatefulWidget {
  final String konamiUser;
  const MainDashboard({super.key, required this.konamiUser});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  // تُمثل قاعدة البيانات اللحظية المربوطة بالـ Scraper تلقائياً
  String _packName = "Epic: Worldwide English League";
  List<Map<String, dynamic>> _currentLivePlayers = [
    {"id": "1", "name": "C. CECH", "rating": 100, "pos": "GK"},
    {"id": "2", "name": "D. DROGBA", "rating": 101, "pos: "CF"},
    {"id": "3", "name": "F. LAMPARD", "rating": 99, "pos": "CMF"}
  ];

  final List<Map<String, dynamic>> _userRadarList = [];

  // دالة محاكاة قيام السيرفر بحذف البكج وضخ بكج جديد في اللعبة
  void _serverAutomatedSync() {
    setState(() {
      // نقل الكروت القديمة في رادار المستخدم لحالة "غير متاح" لأن البكج تم حذفه
      for (var item in _userRadarList) {
        if (item['fromPack'] == _packName) {
          item['isLive'] = false;
        }
      }
      // ضخ البيانات الجديدة الممسوحة من eFootball DB
      _packName = "Epic: Attackers Attack";
      _currentLivePlayers = [
        {"id": "4", "name": "K. RUMMENIGGE", "rating": 101, "pos": "CF"},
        {"id": "5", "name": "D. LAW", "rating": 100, "pos": "CF"},
        {"id": "6", "name": "F. INZAGHI", "rating": 99, "pos": "CF"}
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔄 تحديث السيرفر: تم حذف البكج القديم وضخ الجديد تلقائياً!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121824),
        title: Text('مرحباً: ${widget.konamiUser}', style: const TextStyle(fontSize: 14, color: Color(0xFF00FFAA))),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.amber),
            onPressed: _serverAutomatedSync, // لتجربة التحديث التلقائي الفوري كأنه سيرفر خلفي
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // كارت البكج الحي المتاح داخل اللعبة حالياً
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF162032), Color(0xFF0A0F18)]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF00FFAA).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    justifyAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text(_packName, style: const TextStyle(color: Color(0xFFE5B842), fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0x1F00FFAA), borderRadius: BorderRadius.circular(6)),
                        child: const Text('نشط باللعبة 🟢', style: TextStyle(color: Color(0xFF00FFAA), fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('🃏 اللاعبين المتاحين في البكج الحالي:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // قائمة اللاعبين النشطين
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _currentLivePlayers.length,
                itemBuilder: (context, index) {
                  var p = _currentLivePlayers[index];
                  bool isAdded = _userRadarList.any((element) => element['id'] == p['id']);

                  return Container(
                    width: 110,
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2B210F), Color(0xFF0F0D08)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      border: Border.all(color: const Color(0xFFE5B842), width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFFE5B842),
                          child: Text('${p['rating']}', style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 4),
                        Text(p['name'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        Text(p['pos'], style: const TextStyle(fontSize: 9, color: Colors.grey)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onPressed: () {
                            setState(() {
                              if (isAdded) {
                                _userRadarList.removeWhere((element) => element['id'] == p['id']);
                              } else {
                                _userRadarList.add({...p, 'fromPack': _packName, 'isLive': true});
                              }
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            textAlignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isAdded ? const Color(0xFF00FFAA) : Colors.transparent,
                              border: Border.all(color: const Color(0xFF00FFAA)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                isAdded ? 'مطلوب ✅' : 'رادار 🎯',
                                style: TextStyle(color: isAdded ? Colors.black : const Color(0xFF00FFAA), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 25),
            const Text('🎯 رادارك الشخصي لتتبع المطلوبين:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // رادار تتبع اللاعبين المطلوبين وحالتهم الحية
            Expanded(
              child: _userRadarList.isEmpty 
                ? const Center(child: Text('رادارك فارغ، أضف لاعبين لتتبع توفرهم باللعبة.', style: TextStyle(color: Colors.grey, fontSize: 12)))
                : ListView.builder(
                    itemCount: _userRadarList.length,
                    itemBuilder: (context, index) {
                      var p = _userRadarList[index];
                      return Card(
                        color: const Color(0xFF121824),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('البكج المصاحب: ${p['fromPack']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: p['isLive'] ? const Color(0x1F00FFAA) : const Color(0x1FFF3B69),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p['isLive'] ? 'متوفر حالياً باللعبة' : 'انتهى البكج (غير متاح)',
                              style: TextStyle(color: p['isLive'] ? const Color(0xFF00FFAA) : const Color(0xFFFF3B69), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
