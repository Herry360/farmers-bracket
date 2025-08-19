import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/conversation_card_widget.dart';
import './widgets/empty_messages_widget.dart';
import './widgets/search_bar_widget.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSearchActive = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _filteredConversations = [];

  // Mock conversations data
  final List<Map<String, dynamic>> _mockConversations = [
    {
      "id": 1,
      "name": "Green Valley Farm",
      "avatar":
          "https://images.pexels.com/photos/1300402/pexels-photo-1300402.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastMessage":
          "Your organic tomatoes order is ready for pickup! We harvested them fresh this morning.",
      "timestamp": "2 min ago",
      "unreadCount": 2,
      "isOnline": true,
      "orderContext": "Order #1234 - Organic Tomatoes",
    },
    {
      "id": 2,
      "name": "Sunrise Organic Farm",
      "avatar":
          "https://images.pexels.com/photos/1181534/pexels-photo-1181534.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastMessage":
          "Thank you for your interest in our seasonal vegetables. We have fresh carrots and potatoes available.",
      "timestamp": "15 min ago",
      "unreadCount": 0,
      "isOnline": false,
      "orderContext": "",
    },
    {
      "id": 3,
      "name": "Mountain View Dairy",
      "avatar":
          "https://images.pexels.com/photos/1300402/pexels-photo-1300402.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastMessage":
          "Our fresh milk delivery is scheduled for tomorrow morning. Please confirm your address.",
      "timestamp": "1 hour ago",
      "unreadCount": 1,
      "isOnline": true,
      "orderContext": "Order #1235 - Fresh Milk",
    },
    {
      "id": 4,
      "name": "Harvest Moon Farm",
      "avatar":
          "https://images.pexels.com/photos/1181534/pexels-photo-1181534.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastMessage":
          "We appreciate your bulk order inquiry. Let's discuss pricing for 50kg of wheat.",
      "timestamp": "3 hours ago",
      "unreadCount": 0,
      "isOnline": false,
      "orderContext": "",
    },
    {
      "id": 5,
      "name": "Fresh Fields Co-op",
      "avatar":
          "https://images.pexels.com/photos/1300402/pexels-photo-1300402.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastMessage":
          "Your weekly vegetable box subscription is confirmed. First delivery next Monday!",
      "timestamp": "Yesterday",
      "unreadCount": 0,
      "isOnline": true,
      "orderContext": "Subscription #SUB001",
    },
    {
      "id": 6,
      "name": "Golden Grain Farm",
      "avatar":
          "https://images.pexels.com/photos/1181534/pexels-photo-1181534.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastMessage":
          "Hi! I saw your question about our organic rice. Yes, we have brown and white varieties available.",
      "timestamp": "2 days ago",
      "unreadCount": 0,
      "isOnline": false,
      "orderContext": "",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadConversations() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _conversations = List.from(_mockConversations);
          _filteredConversations = List.from(_conversations);
          _isLoading = false;
        });
      }
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _isSearchActive = query.isNotEmpty;

      if (query.isEmpty) {
        _filteredConversations = List.from(_conversations);
      } else {
        _filteredConversations = _conversations.where((conversation) {
          final name = (conversation["name"] as String).toLowerCase();
          final lastMessage =
              (conversation["lastMessage"] as String).toLowerCase();
          final orderContext =
              (conversation["orderContext"] as String).toLowerCase();

          return name.contains(query) ||
              lastMessage.contains(query) ||
              orderContext.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _conversations = List.from(_mockConversations);
        _filteredConversations = List.from(_conversations);
        _isLoading = false;
      });
    }
  }

  void _markAsRead(int conversationId) {
    setState(() {
      final index =
          _conversations.indexWhere((conv) => conv["id"] == conversationId);
      if (index != -1) {
        _conversations[index]["unreadCount"] = 0;
        _onSearchChanged(); // Refresh filtered list
      }
    });
  }

  void _deleteConversation(int conversationId) {
    setState(() {
      _conversations.removeWhere((conv) => conv["id"] == conversationId);
      _onSearchChanged(); // Refresh filtered list
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Conversation deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Implement undo functionality
            _loadConversations();
          },
        ),
      ),
    );
  }

  void _blockUser(int conversationId) {
    final conversation =
        _conversations.firstWhere((conv) => conv["id"] == conversationId);
    final userName = conversation["name"] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text(
            'Are you sure you want to block $userName? You won\'t receive messages from them anymore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteConversation(conversationId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$userName has been blocked')),
              );
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _openConversation(Map<String, dynamic> conversation) {
    // Mark as read when opening
    _markAsRead(conversation["id"] as int);

    // Navigate to chat detail screen (would be implemented separately)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${conversation["name"]}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _composeNewMessage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Start New Conversation',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 3.h),
              SearchBarWidget(
                hintText: 'Search farmers...',
                isActive: true,
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final farmers = [
                      "Valley Fresh Farm",
                      "Organic Harvest Co.",
                      "Meadow Brook Farm",
                      "Countryside Produce",
                      "Farm Fresh Direct"
                    ];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        child: CustomIconWidget(
                          iconName: 'agriculture',
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(farmers[index]),
                      subtitle: const Text('Tap to start conversation'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Starting chat with ${farmers[index]}')),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 2.0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Messages',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  _onSearchChanged();
                }
              });
            },
            icon: CustomIconWidget(
              iconName: _isSearchActive ? 'close' : 'search',
              color: colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _composeNewMessage,
            icon: CustomIconWidget(
              iconName: 'edit',
              color: colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          if (_isSearchActive)
            SearchBarWidget(
              controller: _searchController,
              onChanged: (value) => _onSearchChanged(),
              onClear: () {
                _searchController.clear();
                _onSearchChanged();
              },
              isActive: _isSearchActive,
            ),

          // Main Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Loading conversations...',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredConversations.isEmpty
                    ? _conversations.isEmpty
                        ? EmptyMessagesWidget(
                            onStartConversation: _composeNewMessage,
                          )
                        : Center(
                            child: Padding(
                              padding: EdgeInsets.all(6.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'search_off',
                                    color: colorScheme.onSurfaceVariant,
                                    size: 64,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'No conversations found',
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Try adjusting your search terms',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: colorScheme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _filteredConversations.length,
                          itemBuilder: (context, index) {
                            final conversation = _filteredConversations[index];

                            return ConversationCardWidget(
                              conversation: conversation,
                              onTap: () => _openConversation(conversation),
                              onMarkRead: () =>
                                  _markAsRead(conversation["id"] as int),
                              onDelete: () => _deleteConversation(
                                  conversation["id"] as int),
                              onBlock: () =>
                                  _blockUser(conversation["id"] as int),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 3, // Messages tab
      ),
      floatingActionButton: _conversations.isNotEmpty
          ? FloatingActionButton(
              onPressed: _composeNewMessage,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: CustomIconWidget(
                iconName: 'add_comment',
                color: colorScheme.onPrimary,
                size: 24,
              ),
            )
          : null,
    );
  }
}