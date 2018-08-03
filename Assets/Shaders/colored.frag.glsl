#version 450

in vec4 fragmentColor;
out vec4 fragColor;

uniform vec2 RENDER_SIZE;

void main() {
	vec4 color = fragmentColor;
	color.rgb *= color.a;
	fragColor = color;
}