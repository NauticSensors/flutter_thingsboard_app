import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/modules/dashboard/di/dashboards_di.dart';
import 'package:thingsboard_app/modules/dashboard/main_dashboard_page.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/controller/dashboard_page_controller.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/widgets/dashboards_appbar.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/widgets/dashboards_grid.dart';
import 'package:thingsboard_app/widgets/two_page_view.dart';
import 'package:thingsboard_app/widgets/ble_scanning_button.dart';

class DashboardsPage extends TbContextWidget {
  DashboardsPage(
    super.tbContext, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DashboardsPageState();
}

class _DashboardsPageState extends TbContextState<DashboardsPage> {
  final pageViewCtrl = TwoPageViewController();
  late final DashboardPageController dashboardPageCtrl;

  late final String diKey;

  @override
  Widget build(BuildContext context) {
    return TwoPageView(
      controller: pageViewCtrl,
      first: DashboardsAppbar(
        tbContext: tbContext,
        body: Stack(
          children: [
            DashboardsGridWidget(
              tbContext: tbContext,
              dashboardPageCtrl: dashboardPageCtrl,
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: BleScanningButton(tbContext: tbContext),
            ),
          ],
        ),
      ),
      second: MainDashboardPage(
        tbContext,
        controller: dashboardPageCtrl,
      ),
    );
  }

  @override
  void initState() {
    diKey = UniqueKey().toString();
    DashboardsDi.init(diKey, tbClient: widget.tbClient);
    dashboardPageCtrl = DashboardPageController(pageCtrl: pageViewCtrl);
    super.initState();
  }

  @override
  void dispose() {
    DashboardsDi.dispose(diKey);
    super.dispose();
  }
}
