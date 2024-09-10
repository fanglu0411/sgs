import 'package:markdown_widget/markdown_widget.dart';

class FitH1Config extends H1Config {
  FitH1Config({super.style});

  @override
  HeadingDivider? get divider => HeadingDivider.h1.copy(color: this.style.color?.withOpacity(.15));
}

class FitH2Config extends H2Config {
  FitH2Config({super.style});

  @override
  HeadingDivider? get divider => HeadingDivider.h2.copy(color: this.style.color?.withOpacity(.15));
}

class FitH3Config extends H3Config {
  FitH3Config({super.style});

  @override
  HeadingDivider? get divider => HeadingDivider.h3.copy(color: this.style.color?.withOpacity(.15));
}
