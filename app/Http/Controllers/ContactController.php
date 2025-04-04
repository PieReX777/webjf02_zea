<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ContactController extends Controller
{
    // Mostrar todos los contactos
    public function index()
    {
        $contacts = auth()->user()->contacts; // Solo los contactos del usuario autenticado
        return view('contacts.index', compact('contacts'));
    }

    // Mostrar formulario para crear un nuevo contacto
    public function create()
    {
        return view('contacts.create');
    }

    // Almacenar un nuevo contacto
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:contacts',
            'phone' => 'nullable|string|max:15',
            'address' => 'nullable|string',
        ]);

        auth()->user()->contacts()->create($request->all()); // Relación con el usuario

        return redirect()->route('contacts.index')->with('success', 'Contacto creado correctamente.');
    }

    // Mostrar formulario para editar un contacto
    public function edit(Contact $contact)
    {
        return view('contacts.edit', compact('contact'));
    }

    // Actualizar un contacto
    public function update(Request $request, Contact $contact)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:contacts,email,' . $contact->id,
            'phone' => 'nullable|string|max:15',
            'address' => 'nullable|string',
        ]);

        $contact->update($request->all());

        return redirect()->route('contacts.index')->with('success', 'Contacto actualizado correctamente.');
    }

    // Eliminar un contacto
    public function destroy(Contact $contact)
    {
        $contact->delete();

        return redirect()->route('contacts.index')->with('success', 'Contacto eliminado correctamente.');
    }
}
