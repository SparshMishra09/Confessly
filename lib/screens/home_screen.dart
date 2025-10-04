import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/confession_provider.dart';
import '../providers/auth_provider.dart';
import '../models/confession_model.dart';
import '../widgets/confession_card.dart';
import 'post_confession_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final confessionProvider = Provider.of<ConfessionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text('Confessly', style: AppTextStyles.heading),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: AppColors.textWhite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort toggle
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSortButton(
                  'Latest',
                  confessionProvider.sortBy == 'latest',
                  () => confessionProvider.toggleSort(),
                ),
                SizedBox(width: 16),
                _buildSortButton(
                  'Trending',
                  confessionProvider.sortBy == 'trending',
                  () => confessionProvider.toggleSort(),
                ),
              ],
            ),
          ),
          
          // Confession feed
          Expanded(
            child: StreamBuilder<List<Confession>>(
              stream: confessionProvider.getConfessionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading confessions',
                      style: AppTextStyles.body,
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📭', style: TextStyle(fontSize: 60)),
                        SizedBox(height: 16),
                        Text(
                          'No confessions yet',
                          style: AppTextStyles.subheading,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Be the first to share!',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }
                
                List<Confession> confessions = snapshot.data!;
                
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 80),
                  itemCount: confessions.length,
                  itemBuilder: (context, index) {
                    return ConfessionCard(
                      confession: confessions[index],
                      onReaction: (emoji) {
                        if (authProvider.user != null) {
                          confessionProvider.addReaction(
                            confessions[index].id,
                            emoji,
                            authProvider.user!.uid,
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostConfessionScreen()),
          );
        },
        backgroundColor: AppColors.primaryPurple,
        icon: Icon(Icons.add, size: 28),
        label: Text('Confess', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSortButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryPurple,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.body.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}