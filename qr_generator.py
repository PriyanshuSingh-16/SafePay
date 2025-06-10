import qrcode
import os

def generate_qr_code(data, filename, fill_color="black", back_color="white"):
    """
    Generates a QR code with the given data and saves it to a file.

    Args:
        data (str): The content to be encoded in the QR code.
        filename (str): The name of the file to save the QR code image (e.g., "safe_qr.png").
        fill_color (str): The color of the QR code modules (default: "black").
        back_color (str): The background color of the QR code (default: "white").
    """
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)

    img = qr.make_image(fill_color=fill_color, back_color=back_color)
    img.save(filename)
    print(f"Generated '{filename}' with content: '{data}'")

if __name__ == "__main__":
    # Create a directory to store the QR codes
    output_dir = "mock_qrcodes"
    os.makedirs(output_dir, exist_ok=True)

    # 1. Safe QR Code
    safe_upi_qr_content = "upi://pay?pa=yourname@bank&pn=YourName&mc=0000"
    generate_qr_code(safe_upi_qr_content, os.path.join(output_dir, "safe_upi_qr.png"))

    safe_url_qr_content = "https://www.example.com/safe_page"
    generate_qr_code(safe_url_qr_content, os.path.join(output_dir, "safe_url_qr.png"))

    # 2. Suspicious QR Code (triggers length or keyword check)
    # This URL is intentionally long and contains a 'verify-account' like keyword.
    suspicious_qr_content = (
        "https://suspicious-long-domain.info/verify-account-security-update-now-or-your-account-will-be-locked/"
        "please-click-here-to-reconfirm-your-details-immediately-avoid-disruption-to-service-important-notice"
    )
    generate_qr_code(suspicious_qr_content, os.path.join(output_dir, "suspicious_long_url_qr.png"))

    # 3. Malicious QR Code (triggers known malicious domain)
    malicious_domain_qr_content = "https://phishing.xyz/login?session=expired"
    generate_qr_code(malicious_domain_qr_content, os.path.join(output_dir, "malicious_domain_qr.png"))

    # 4. Malicious QR Code (triggers simulated LSB steganography detection)
    # This content includes the specific marker your backend is looking for to simulate LSB alteration detection.
    lsb_modified_qr_content = "https://legit-website.com/data?id=123&payload=LSB_MODIFIED_DATA_HIDDEN_SECRET_CODE_ABCDEF"
    generate_qr_code(lsb_modified_qr_content, os.path.join(output_dir, "malicious_lsb_steganography_qr.png"))

    print(f"\nMock QR codes generated in the '{output_dir}' directory.")
    print("You can now scan these QR codes with your SafePay QR app to test the different classification scenarios.")
