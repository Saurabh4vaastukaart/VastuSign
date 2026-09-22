"""Apply VastuSign settings to a freshly generated Flutter Android runner."""

from pathlib import Path


manifest_path = Path("android/app/src/main/AndroidManifest.xml")
manifest = manifest_path.read_text(encoding="utf-8")

permissions = """    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.sensor.compass" android:required="false" />
"""

if "android.permission.CAMERA" not in manifest:
    closing = manifest.find(">") + 1
    manifest = manifest[:closing] + "\n" + permissions + manifest[closing:]

manifest = manifest.replace('android:label="vastusign"', 'android:label="VastuSign"')
manifest_path.write_text(manifest, encoding="utf-8")
