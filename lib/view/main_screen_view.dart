import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '../controller/main_screen_controller.dart';

class MainScreenView extends StatelessWidget {
  MainScreenView({super.key});
// we can replace it with getBuilder and user there is controller
//  MainScreenController controller = Get.put(MainScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Image.asset('assets/images/tfl_logo.png'),
          backgroundColor: Colors.black.withOpacity(1),
        ),
        body: GetBuilder<MainScreenController>(
          init: MainScreenController(),
          builder: (controller) {
            return controller.showError
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('there is an error'),
                          ],
                        ),
                      ])
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.classification.length,
                    itemBuilder: (context, index) {
                      final item = controller.classification[index];
                      return Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(item.key),
                          ),
                          Flexible(
                              child: LinearProgressIndicator(
                            backgroundColor:
                                controller.backgroundProgressColorList[index %
                                    controller
                                        .backgroundProgressColorList.length],
                            color: controller.primaryProgressColorList[index %
                                controller.primaryProgressColorList.length],
                            value: item.value,
                            minHeight: 20,
                          ))
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(
                      height: 10,
                    ),
                  );
          },
        ));
  }
}
