import streamlit as st
import base64

def render_image(filepath: str, width: int = None):
    mime_type = filepath.split('.')[-1:][0].lower()
    if mime_type == 'svg':
        mime_type = 'svg+xml'
    with open(filepath, "rb") as f:
        content_bytes = f.read()
    content_b64encoded = base64.b64encode(content_bytes).decode()
    image_string = f'data:image/{mime_type};base64,{content_b64encoded}'
    if width:
        st.image(image_string, width=width)
    else:
        st.image(image_string)

def get_image_base64(filepath: str) -> str:
    mime_type = filepath.split('.')[-1:][0].lower()
    if mime_type == 'svg':
        mime_type = 'svg+xml'
    with open(filepath, "rb") as f:
        content_bytes = f.read()
    content_b64encoded = base64.b64encode(content_bytes).decode()
    return f'data:image/{mime_type};base64,{content_b64encoded}'
