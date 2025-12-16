import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final List<PieChartSectionData> chartSections = [
    // done
    PieChartSectionData(
      value: 30,
      color: Colors.greenAccent,
      title: '30%',
      radius: 60,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    // in progress
    PieChartSectionData(
      value: 35,
      color: Colors.deepPurpleAccent,
      title: '35%',
      radius: 60,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    //pending
    PieChartSectionData(
      value: 15,
      color: Colors.redAccent,
      title: '15%',
      radius: 60,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 14),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/ProjectBoard');
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.only(left: 33),
            child: Text(
              "Analytics",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
              height: 480,
              width: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xFFF5F7FB),
              ),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15, top: 18),
                    child: Text(
                      "Project Analytics",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 350,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: chartSections,
                      ),
                    ),
                  ),
                  Column(
                    children: const [
                      LegendItem(color: Colors.deepPurpleAccent, text: 'In progress'),
                      LegendItem(color: Colors.redAccent, text: 'Pending'),
                      LegendItem(color: Colors.greenAccent, text: 'Completed'),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF4169E1),
        unselectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home,color:Colors.white,),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month,color:Colors.white,),
            label: 'Upcoming',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,color:Colors.white,),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.lightBlueAccent,
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 20,),
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}