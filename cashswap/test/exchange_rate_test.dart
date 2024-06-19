import 'package:cashswap/my_home_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashswap/main.dart'; // Adjust the import to match your project structure

void main() {
  test('Calculate amount after commission', () {
    // Define the input values
    double baseRateValue = 0.002;
    double commissionPercentage = 10.0;
    double commissionFlat = 0.0; // No flat commission for this test

    // Calculate the expected output
    double expectedOutput = 0.0018;

    // Call the function and get the result
    double result = 0.0;
    // result = calculateAmountAfterCommission(baseRateValue, commissionPercentage, commissionFlat);

    // Verify the result
    expect(result, expectedOutput);
  });
}
