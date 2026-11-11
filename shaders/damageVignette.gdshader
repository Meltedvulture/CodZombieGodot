shader_type canvas_item;

// Exposed parameters
uniform vec4 vignette_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Default to Red
uniform float intensity : hint_range(0.0, 1.0) = 0.0; // 0.0 = Hidden, 1.0 = Max Red

void fragment() {
    // Center the UV coordinates (-1.0 to 1.0)
    vec2 uv = UV * 2.0 - 1.0;
    float distance_from_center = length(uv);
    
    // Dynamically calculate the radius and softness based on intensity
    // As intensity goes up, the vignette creeps closer to the center
    float radius = mix(1.5, 0.4, intensity); 
    float softness = mix(0.8, 0.3, intensity);
    
    // Calculate vignette shape
    float vignette = smoothstep(radius, radius - softness, distance_from_center);
    
    // Scale the final alpha transparency by the intensity
    float final_alpha = (1.0 - vignette) * intensity * vignette_color.a;
    
    COLOR = vec4(vignette_color.rgb, final_alpha);
}
