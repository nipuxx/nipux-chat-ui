// Test script to verify arena model filtering logic
const testModels = [
    { id: 'model1', name: 'Regular Model 1', owned_by: 'ollama' },
    { id: 'model2', name: 'Regular Model 2', owned_by: 'openai' },
    { id: 'arena-model', name: 'Arena Model', owned_by: 'arena' },
    { id: 'model3', name: 'Model with arena flag', arena: true },
    { id: 'model4', name: 'Hidden Model', info: { meta: { hidden: true } } },
    { id: 'model5', name: 'Normal Model', owned_by: 'ollama' }
];

// Test the filtering logic
const filteredModels = testModels.filter((m) => 
    !(m?.info?.meta?.hidden ?? false) && 
    !(m?.owned_by === 'arena' || m?.arena === true)
);

console.log('Original models:', testModels.length);
console.log('Filtered models:', filteredModels.length);
console.log('Filtered model names:', filteredModels.map(m => m.name));

// Expected: Should exclude arena-model, model with arena flag, and hidden model
// Should include: Regular Model 1, Regular Model 2, Normal Model
const expectedNames = ['Regular Model 1', 'Regular Model 2', 'Normal Model'];
const actualNames = filteredModels.map(m => m.name);

console.log('Test passed:', JSON.stringify(expectedNames.sort()) === JSON.stringify(actualNames.sort())); 