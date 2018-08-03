#version 450

in vec3 position;
in vec2 texuv;
in vec4 color;

out vec4 fragmentColor;
out vec2 texCoord;

uniform mat4 MVP_MATRIX;
uniform vec2 RENDER_SIZE;

void main() {
	gl_Position = MVP_MATRIX * vec4(position, 1.0);
	fragmentColor = color;
	texCoord = texuv;
}