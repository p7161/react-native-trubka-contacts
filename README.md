# react-native-trubka-contacts

Fast asynchronous normalization of contacts phone numbers from React Native using the classic bridge.

## Installation

```bash
npm install react-native-trubka-contacts
# or
yarn add react-native-trubka-contacts
```

### iOS

1. Install pods:
   ```bash
   cd ios && pod install
   ```
2. The module is distributed as a Swift pod. If your Podfile uses `use_frameworks!`, prefer `:linkage => :static` to keep the binary size small.

### Android

The library targets `compileSdkVersion 34` and requires `minSdkVersion 23`.

### Expo

The module works in Expo Dev Client (via `expo prebuild` + `expo run`). It does **not** run inside Expo Go because it ships native code.

## Usage

```ts
import TrubkaContacts, { type InputContact } from 'react-native-trubka-contacts';

const contacts: InputContact[] = [
  {
    firstName: 'Maria',
    lastName: 'Ivanova',
    phones: ['8 (999) 123-45-67', '+7 999 123 45 67']
  }
];

const rows = await TrubkaContacts.process(contacts, {
  regionHint: 'RU',
  formatInternational: true,
});

console.log(rows);
// => [
//   {
//     id: '79991234567',
//     first_name: 'Maria',
//     last_name: 'Ivanova',
//     name: '',
//     phone_number: '79991234567',
//     phone_number_formatted: '+7 999 123-45-67'
//   }
// ]
```

## API

```ts
process(contacts: InputContact[], options?: ProcessOptions): Promise<ProcessedRow[]>
```

- Heavy lifting happens on background threads both on iOS and Android.
- Numbers are deduplicated by their E.164 digits without the leading `+`.
- Raw digits are normalized by stripping non-digits, trimming the `00` prefix and converting Russian `8XXXXXXXXXX` into `7XXXXXXXXXX`.
- When `formatInternational` is `true`, the international representation is included alongside the digit-only value.
- Errors reject the promise with code `trubka_contacts_error`.

## License

MIT
