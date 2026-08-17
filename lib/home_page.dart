import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metro_app/station.dart';
import 'package:url_launcher/url_launcher.dart';
import 'stations_data.dart';
import 'location_fun.dart';
import 'app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Station? fromStation;
  Station? toStation;
  Station? nearestStationFromCurrent;
  Station? nearestStationFromDestination;
  final showLocationField = false.obs;
  final answer1 = TextEditingController();
  final answer2 = TextEditingController();
  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();
  final answer3 = TextEditingController();
  final answer4 = TextEditingController();
  final locationController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    answer1.dispose();
    answer2.dispose();
    answer3.dispose();
    answer4.dispose();
    locationController.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 32),
              _buildStationInputSection(isDark),
              const SizedBox(height: 24),
              _buildPassengerDetailsSection(isDark),
              const SizedBox(height: 32),
              _buildMainActionButton(),
              const SizedBox(height: 32),
              _buildLocationServicesSection(isDark),
              const SizedBox(height: 16),
              Obx(() => _buildDestinationAddressSection(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'plan_new_ride'.tr,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF2D3748),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.directions_subway_rounded,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'plan_your_journey'.tr,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'find_fastest_between'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationInputSection(bool isDark) {
    return Column(
      children: [
        _buildAnimatedStationCard(
          isDark: isDark,
          controller: answer1,
          focusNode: focusNode1,
          label: 'departure_station'.tr,
          icon: Icons.location_pin,
          iconColor: const Color(0xFFEF4444),
          onMapPressed: () => _openStationOnMap(answer1, fromStation),
          onSelected: (station) => fromStation = station,
        ),
        const SizedBox(height: 16),
        _buildAnimatedStationCard(
          isDark: isDark,
          controller: answer2,
          focusNode: focusNode2,
          label: 'arrival_station'.tr,
          icon: Icons.location_pin,
          iconColor: const Color(0xFF10B981),
          onMapPressed: () => _openStationOnMap(answer2, toStation),
          onSelected: (station) => toStation = station,
        ),
      ],
    );
  }

  Widget _buildAnimatedStationCard({
    required bool isDark,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onMapPressed,
    required Function(Station?) onSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RawAutocomplete<Station>(
                    focusNode: focusNode,
                    textEditingController: controller,
                    displayStringForOption: (Station option) => option.name.tr,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return metroStations;
                      }
                      return metroStations.where((Station option) {
                        return option.name.tr
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (Station selection) {
                      controller.text = selection.name.tr;
                      onSelected(selection);
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'select_station'.tr,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      );
                    },
                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<Station> onSelectedAuto,
                        Iterable<Station> options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 8.0,
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 200,
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Station option = options.elementAt(index);
                                return InkWell(
                                  onTap: () {
                                    onSelectedAuto(option);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    child: Text(
                                      option.name.tr,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.map_outlined, color: Color(0xFF4F46E5)),
              onPressed: onMapPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerDetailsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'passenger_details'.tr,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailInputField(
                  isDark: isDark,
                  controller: answer3,
                  hintText: 'passenger_age'.tr,
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailInputField(
                  isDark: isDark,
                  controller: answer4,
                  hintText: 'special_needs'.tr,
                  icon: Icons.accessible_outlined,
                  iconColor: const Color(0xFF10B981),
                  isDropdown: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInputField({
    required bool isDark,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    bool isDropdown = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: isDropdown
                ? DropdownMenu(
                    controller: controller,
                    width: MediaQuery.of(context).size.width * 0.3,
                    hintText: hintText,
                    textStyle: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    inputDecorationTheme: const InputDecorationTheme(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: 'yes', label: 'yes'.tr),
                      DropdownMenuEntry(value: 'no', label: 'no'.tr),
                    ],
                  )
                : TextField(
                    controller: controller,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 12),
                    ),
                    keyboardType: TextInputType.number,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    return ElevatedButton(
      onPressed: _handleShowDetails,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4F46E5),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
        shadowColor: const Color(0xFF4F46E5).withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            'calculate_route'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationServicesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'location_services'.tr,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLocationServiceButton(
                text: 'nearest_station_from'.tr,
                icon: Icons.near_me,
                color: const Color(0xFF10B981),
                onPressed: () async {
                  nearestStationFromCurrent = await findNearestStationFromCurrent();
                  if (nearestStationFromCurrent != null) {
                    answer1.text = nearestStationFromCurrent!.name.tr;
                    fromStation = nearestStationFromCurrent;
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLocationServiceButton(
                text: 'enter_destination'.tr,
                icon: Icons.location_searching,
                color: const Color(0xFFF59E0B),
                onPressed: () {
                  showLocationField.value = !showLocationField.value;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationServiceButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationAddressSection(bool isDark) {
    return showLocationField.value
        ? Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'enter_destination'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.map_outlined, color: Color(0xFFF59E0B), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: locationController,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'enter_destination'.tr,
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(bottom: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLocationActionButton(
                            text: 'search_nearest'.tr,
                            icon: Icons.search,
                            color: const Color(0xFF3B82F6),
                            onPressed: () async {
                              if (locationController.text.isEmpty) {
                                _showErrorSnackbar('please_fill_fields'.tr);
                                return;
                              }
                              nearestStationFromDestination =
                                  await findNearestToEnteredAddress(locationController);
                              if (nearestStationFromDestination != null) {
                                answer2.text = nearestStationFromDestination!.name.tr;
                                toStation = nearestStationFromDestination;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget _buildLocationActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openStationOnMap(TextEditingController controller, Station? station) {
    if (station != null) {
      launchUrl(Uri.parse(
        'geo:0,0?q=${station.name}+metro+station+egypt',
      ));
    } else {
      _showErrorSnackbar('please_select_station'.tr);
    }
  }

  void _handleShowDetails() {
    if (fromStation == null ||
        toStation == null ||
        answer3.text.isEmpty ||
        answer4.text.isEmpty) {
      _showErrorSnackbar('please_fill_fields'.tr);
      return;
    }

    Get.toNamed(
      AppRoutes.details,
      arguments: {
        'from': fromStation!.name,
        'to': toStation!.name,
        'age': answer3.text,
        'disabled': answer4.text,
      },
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      animationDuration: const Duration(milliseconds: 300),
    );
  }
}