import { NativeModules } from 'react-native';

export type InputContact = {
  firstName?: string;
  lastName?: string;
  name?: string;
  phones: string[];
};

export type ProcessOptions = {
  regionHint?: string;
  formatInternational?: boolean;
};

export type ProcessedRow = {
  id: string;
  first_name: string;
  last_name: string;
  name: string;
  phone_number: string;
  phone_number_formatted?: string | null;
};

const { TrubkaContacts } = NativeModules as {
  TrubkaContacts?: {
    process(contacts: InputContact[], options?: ProcessOptions): Promise<ProcessedRow[]>;
  };
};

if (!TrubkaContacts) {
  console.warn(
    '[react-native-trubka-contacts] Native module not found. Are you running in Expo Go or missing pod/gradle install?'
  );
}

export async function process(
  contacts: InputContact[],
  options: ProcessOptions = {}
): Promise<ProcessedRow[]> {
  if (!TrubkaContacts) {
    return [];
  }

  return TrubkaContacts.process(contacts, options);
}

export default {
  process,
};
