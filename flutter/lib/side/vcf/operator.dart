bool operator(String operator, value, targetValue) {
  switch (operator) {
    case '<':
      return (value) < (targetValue);
      break;
    case '<=':
      return (value) <= (targetValue);
      break;
    case '==':
      return (value) == (targetValue);
      break;
    case '>':
      return (value) > (targetValue);
      break;
    case '>=':
      return (value) >= (targetValue);
      break;
  }
  return false;
}
