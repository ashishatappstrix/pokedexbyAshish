//
//  ViewController.swift
//  pokedex-by-ashish
//
//  Created by Ashh on 2/26/16.
//  Copyright © 2016 appstrix. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collection:UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pokemon = [Pokemon]()
    var filteredPokemon = [Pokemon]()
    var musicplayer: AVAudioPlayer!
    var inSearchMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        collection.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.Done
        initAudio()
        parsePokemonCSV()
    }
    
    func initAudio() {
        
        let path = NSBundle.mainBundle().pathForResource("music", ofType: "mp3")!
        
        do{
            musicplayer = try AVAudioPlayer(contentsOfURL: NSURL(string: path)!)
            musicplayer.prepareToPlay()
            musicplayer.numberOfLoops = -1
            musicplayer.play()
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    func parsePokemonCSV() {
        
        let path = NSBundle.mainBundle().pathForResource("pokemon", ofType: "csv")!
       
        do{
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]!
                let poke = Pokemon(name: name, pokedexId: pokeId)
                pokemon.append(poke)
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
    }
    
    
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
          
            // Reuses cell instead of creating 718 images
            //Dequeue - grab one which is off screen and put used ones
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PokeCell", forIndexPath: indexPath) as? PokeCell {
                
                let  poke: Pokemon!
                if inSearchMode {
                    poke = filteredPokemon[indexPath.row]
                }else{
                    poke = pokemon[indexPath.row]
                }
                
                cell.configureCell(poke)
                return cell
                
            } else {
                return UICollectionViewCell()
            }
        }
        
        func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
            
            let poke: Pokemon!
           
            if inSearchMode {
                poke = filteredPokemon[indexPath.row]
            } else {
                poke = pokemon[indexPath.row]
            }
            
            performSegueWithIdentifier("PokemonDetailVC", sender: poke)
           
        }
       
        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if inSearchMode {
                return filteredPokemon.count
                
            }
            return pokemon.count
        }
    
         func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
           return 1
         }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(105,105)
    }
    
    
 
    @IBAction func musicBtnPressed(sender: UIButton!) {
        
        if musicplayer.playing {
            musicplayer.stop()
            sender.alpha = 0.2
        } else {
            musicplayer.play()
            sender.alpha = 1.0
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            view.endEditing(true)
            collection.reloadData()
        } else {
            inSearchMode = true
            let lower = searchBar.text!.lowercaseString
            filteredPokemon = pokemon.filter({$0.name.rangeOfString(lower) != nil})
            collection.reloadData()
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailsVC = segue.destinationViewController as? PokemonDetailVC {
                if let poke = sender as? Pokemon {
                    detailsVC.pokemon = poke
                }
            }
        }
    }
}

