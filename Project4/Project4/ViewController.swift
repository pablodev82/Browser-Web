//
//  ViewController.swift
//  Project4
//
//  Created by Admin on 28/07/2024.
//


import UIKit
import WebKit

// Este controlador muestra una lista de sitios web en una tabla.
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    var websites = ["apple.com", "hackingwithswift.com", "google.com", "stackoverflow.com", "openai.com"] // Lista de sitios web permitidos.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sitios Web" // Título de la pantalla.
        
        // Configurar la tabla.
        tableView = UITableView() // Crear una nueva instancia de UITableView.
        tableView.dataSource = self // Establecer el ViewController como el data source de la tabla.
        tableView.delegate = self // Establecer el ViewController como el delegado de la tabla.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Website") // Registrar el tipo de celda que se utilizará.
        view.addSubview(tableView) // Añadir la tabla como subvista.
        
        // Configurar restricciones para la tabla.
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor), // Restricción superior.
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor), // Restricción inferior.
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor), // Restricción izquierda.
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor) // Restricción derecha.
        ])
    }
    
    // Métodos de UITableViewDataSource y UITableViewDelegate.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // La tabla tiene una sección.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count // El número de filas es igual al número de sitios web.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Website", for: indexPath) // Obtener una celda reutilizable.
        cell.textLabel?.text = websites[indexPath.row] // Establecer el texto de la celda como el nombre del sitio web.
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webViewController = WebViewController() // Crear una instancia de WebViewController.
        webViewController.website = websites[indexPath.row] // Pasar el sitio web seleccionado al WebViewController.
        navigationController?.pushViewController(webViewController, animated: true) // Navegar al WebViewController.
    }
}

// Este controlador muestra una página web seleccionada en una vista web.
class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var website: String?
    var observerAdded = false // Controla si el observador fue añadido.

    override func loadView() {
        webView = WKWebView() // Crear una nueva instancia de WKWebView.
        webView.navigationDelegate = self // Establecer el WebViewController como delegado de navegación.
        view = webView // Establecer la vista principal como la webView.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView = UIProgressView(progressViewStyle: .default) // Crear una instancia de UIProgressView.
        progressView.sizeToFit() // Ajustar el tamaño de la vista de progreso.
        let progressButton = UIBarButtonItem(customView: progressView) // Crear un botón de barra con la vista de progreso.
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) // Crear un espacio flexible.
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload)) // Botón de recarga.
        
        // Nuevos botones para navegar hacia atrás y hacia adelante.
        let back = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack)) // Botón de retroceso.
        let forward = UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(goForward)) // Botón de avance.
        
        toolbarItems = [progressButton, spacer, back, spacer, forward, spacer, refresh] // Configurar los elementos de la barra de herramientas.
        navigationController?.isToolbarHidden = false // Mostrar la barra de herramientas.
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil) // Añadir observador para el progreso de carga.
        observerAdded = true // Marcar que el observador fue añadido.
        
        if let website = website { // Si se proporcionó un sitio web.
            let url = URL(string: "https://" + website)! // Crear una URL a partir del sitio web.
            webView.load(URLRequest(url: url)) // Cargar la URL en la webView.
            webView.allowsBackForwardNavigationGestures = true // Permitir gestos de navegación.
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if observerAdded { // Si el observador fue añadido.
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress)) // Eliminar el observador.
        }
    }
    
    @objc func goBack() {
        if webView.canGoBack { // Si la webView puede ir hacia atrás.
            webView.goBack() // Ir hacia atrás.
        }
    }
    
    @objc func goForward() {
        if webView.canGoForward { // Si la webView puede ir hacia adelante.
            webView.goForward() // Ir hacia adelante.
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" { // Si la clave observada es "estimatedProgress".
            progressView.progress = Float(webView.estimatedProgress) // Actualizar la barra de progreso.
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title // Establecer el título de la vista con el título de la página web.
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url // Obtener la URL de la solicitud de navegación.
        
        if let host = url?.host { // Si la URL tiene un host.
            if let website = website, host.contains(website) { // Si el host contiene el sitio web permitido.
                decisionHandler(.allow) // Permitir la navegación.
                return
            }
        }
        
        decisionHandler(.cancel) // Cancelar la navegación.
    }
}


