package com.trubkacontacts

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.google.i18n.phonenumbers.NumberParseException
import com.google.i18n.phonenumbers.PhoneNumberUtil
import java.util.Locale
import java.util.concurrent.Executors

class TrubkaContactsModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  private val phoneUtil: PhoneNumberUtil = PhoneNumberUtil.getInstance()
  private val executor = Executors.newSingleThreadExecutor()

  override fun getName(): String = "TrubkaContacts"

  @ReactMethod
  fun process(contacts: ReadableArray, options: ReadableMap?, promise: Promise) {
    executor.execute {
      try {
        val result = processInternal(contacts, options)
        promise.resolve(result)
      } catch (error: Exception) {
        promise.reject("trubka_contacts_error", error)
      }
    }
  }

  private fun processInternal(contacts: ReadableArray, options: ReadableMap?): WritableArray {
    val regionHint = options?.let {
      if (it.hasKey("regionHint") && !it.isNull("regionHint")) {
        it.getString("regionHint")?.uppercase(Locale.US)
      } else {
        null
      }
    }
    val formatInternational = options?.let {
      it.hasKey("formatInternational") && !it.isNull("formatInternational") && it.getBoolean("formatInternational")
    } ?: false

    val dedup = HashSet<String>()
    val output = Arguments.createArray()

    for (i in 0 until contacts.size()) {
      val contact = contacts.getMap(i) ?: continue
      val firstName = contact.getString("firstName") ?: ""
      val lastName = contact.getString("lastName") ?: ""
      val name = contact.getString("name") ?: ""
      val phones = contact.getArray("phones") ?: continue

      for (j in 0 until phones.size()) {
        val rawPhone = phones.getString(j) ?: continue
        val normalized = normalize(rawPhone)
        if (normalized.isEmpty()) continue

        val parsed = parseNumber(normalized, regionHint) ?: continue
        val e164 = phoneUtil.format(parsed, PhoneNumberUtil.PhoneNumberFormat.E164)
        if (!e164.startsWith("+")) continue
        val id = e164.substring(1)
        if (id.isEmpty() || dedup.contains(id)) continue
        dedup.add(id)

        val row: WritableMap = Arguments.createMap()
        row.putString("id", id)
        row.putString("first_name", firstName)
        row.putString("last_name", lastName)
        row.putString("name", name)
        row.putString("phone_number", id)

        if (formatInternational) {
          val formatted = phoneUtil.format(parsed, PhoneNumberUtil.PhoneNumberFormat.INTERNATIONAL)
          row.putString("phone_number_formatted", formatted)
        } else {
          row.putNull("phone_number_formatted")
        }

        output.pushMap(row)
      }
    }

    return output
  }

  private fun normalize(raw: String): String {
    var digits = raw.filter { it.isDigit() }

    while (digits.startsWith("00")) {
      digits = digits.substring(2)
    }

    if (digits.length == 11 && digits.startsWith("8")) {
      digits = "7" + digits.substring(1)
    }

    return digits
  }

  private fun parseNumber(
    normalized: String,
    regionHint: String?
  ): com.google.i18n.phonenumbers.Phonenumber.PhoneNumber? {
    if (normalized.isEmpty()) {
      return null
    }

    try {
      return phoneUtil.parse("+$normalized", null)
    } catch (_: NumberParseException) {
      // fallthrough
    }

    if (regionHint != null) {
      try {
        return phoneUtil.parse(normalized, regionHint)
      } catch (_: NumberParseException) {
        // fallthrough
      }
    }

    val defaultRegion = Locale.getDefault().country.takeIf { it.isNotEmpty() }
    if (defaultRegion != null) {
      try {
        return phoneUtil.parse(normalized, defaultRegion)
      } catch (_: NumberParseException) {
        // fallthrough
      }
    }

    return null
  }
}
