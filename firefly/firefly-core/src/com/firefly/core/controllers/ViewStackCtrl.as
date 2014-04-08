package com.firefly.core.controllers
{
	import com.firefly.core.controllers.helpers.ViewState;
	import com.firefly.core.display.IView;
	import com.firefly.core.display.IViewStack;
	import com.firefly.core.utils.ClassFactory;
	
	import flash.utils.Dictionary;

	public class ViewStackCtrl
	{
		private var _max:int = 1;
		private var _views:Dictionary;
		private var _openedViews:Vector.<ViewState>;
		private var _viewStack:IViewStack;
		
		public function ViewStackCtrl(viewStack:IViewStack, max:int = 1)
		{
			_max = max;
			_viewStack = viewStack;
			_views = new Dictionary();
			_openedViews = new Vector.<ViewState>();
		}
		
		public function regState(state:ViewState):void
		{
			_views[state.name] = state;
		}
		
		public function regView(name:String, factory:ClassFactory, cache:Boolean = true):void
		{
			_views[name] = new ViewState(name, factory, "", cache);
		}
		
		public function show(name:String, data:Object = null):IView
		{
			var state:ViewState = _views[name];
			if(state)
			{
				var view:IView = _views[name].getInstance();
				if(view)
				{
					_viewStack.addView(view);
					
					if(_openedViews.length == _max)
						hideState(_openedViews[0]);
					
					_openedViews.push(state);
					
					view.show(data);
					
					return view;
				}
			}
			
			return null;
		}
		
		public function hide(name:String):ViewState
		{
			for each (var state:ViewState in _openedViews) 
			{
				if(state.name == name)
					return hideState(state);
			}
			
			return null; 
		}
		
		public function hideTop():ViewState
		{
			if(_openedViews.length > 0)
				return hideState(_openedViews[_openedViews.length-1]);
			
			return null;
		}
		
		public function hideAll():void
		{
			while(_openedViews.length > 0)
			{
				hideState(_openedViews[_openedViews.length-1]);
			}
		}
		
		protected function hideState(state:ViewState):ViewState
		{
			var index:int = _openedViews.indexOf(state);
			if(index > -1)
				_openedViews.splice(index, 1);
			
			_viewStack.removeView(state.instance);
			state.instance.hide();
			
			return state;
		}
		
		public function get topState():ViewState
		{
			return _openedViews.length > 0 ? _openedViews[_openedViews.length-1] : null;
		}
		
		public function getState(name:String):ViewState
		{
			return _views[name];
		}
	}
}