import 'package:agentic_base/src/observability/operator_report_renderer.dart';
import 'package:agentic_base/src/observability/run_ledger.dart';
import 'package:agentic_base/src/observability/telemetry_bundle.dart';

class RunInspection {
  const RunInspection({
    required this.bundle,
    required this.ledger,
    required this.markdown,
  });

  final TelemetryBundle bundle;
  final RunLedger ledger;
  final String markdown;
}

class RunEventReporter {
  const RunEventReporter();

  RunInspection inspect(String runDirectoryPath) {
    final bundle = TelemetryBundle.load(runDirectoryPath);
    final ledger = RunLedger.fromBundle(bundle);
    final markdown = const OperatorReportRenderer().renderMarkdown(ledger);
    return RunInspection(
      bundle: bundle,
      ledger: ledger,
      markdown: markdown,
    );
  }
}
